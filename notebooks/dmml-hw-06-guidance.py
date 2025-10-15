import optuna
import polars as pl
import scipy
from sklearn.base import BaseEstimator
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import classification_report, f1_score, roc_auc_score
from sklearn.model_selection import (
    RandomizedSearchCV,
    StratifiedKFold,
    cross_val_score,
    cross_validate,
    train_test_split,
)
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder


def create_pipeline_from_classifier(clf: BaseEstimator) -> Pipeline:
    pipeline = Pipeline(
        steps=[
            (
                "preprocessor",
                ColumnTransformer(
                    transformers=[
                        ("ag_ratio", SimpleImputer(strategy="median"), ["A/G Ratio"]),
                        ("gender", OneHotEncoder(handle_unknown="ignore", drop="first"), ["Gender"]),
                    ],
                    remainder="passthrough",
                    verbose_feature_names_out=False,
                ),
            ),
            ("model", clf),
        ]
    )

    return pipeline


def validate_model(
    model: BaseEstimator,
    X_train: pl.DataFrame,
    y_train: pl.Series,
    cv_number_of_splits: int,
    random_state: int,
) -> dict:
    cv: StratifiedKFold = StratifiedKFold(n_splits=cv_number_of_splits, shuffle=True, random_state=random_state)
    scores = cross_validate(
        model,
        X_train,  # type: ignore
        y_train,
        cv=cv,
        scoring=["roc_auc", "accuracy"],
        return_train_score=True,
        verbose=0,
    )
    print(f"Cross-validated ROC-AUC score: {scores['test_roc_auc'].mean():.4f} ± {scores['test_roc_auc'].std():.4f}")
    return scores


def evaluate_model_on_test(model: BaseEstimator, X: pl.DataFrame, y_true: pl.Series) -> dict:
    scores = {
        "roc_auc": roc_auc_score(y_true, model.predict_proba(X)[:, 1]),  # type: ignore
        "accuracy": (y_true == model.predict(X)).mean(),  # type: ignore
        "f1": f1_score(y_true, model.predict(X)),  # type: ignore
    }

    print("Test ROC-AUC:", scores["roc_auc"])
    # print("Test Accuracy:", scores["accuracy"])
    # print("Test F1 Score:", scores["f1"])
    print(classification_report(y_true, model.predict(X)))  # type: ignore

    return scores


def main() -> None:
    RANDOM_STATE = 42
    CV_FOLDS = 5

    df = pl.read_csv("./data/liver_disorders.csv")
    df = df.unique()

    X, y = df.drop("Selector"), df["Selector"]
    X_train, X_test, y_train, y_test = train_test_split(
        X.to_pandas(), y.to_pandas(), test_size=0.4, random_state=RANDOM_STATE, stratify=y
    )
    print(f"Train set size: {X_train.shape[0]}, Test set size: {X_test.shape[0]}")

    # Unoptimized model for baseline
    clf = RandomForestClassifier(random_state=RANDOM_STATE)
    pipeline = create_pipeline_from_classifier(clf)

    _cv_scores = validate_model(pipeline, X_train, y_train, CV_FOLDS, RANDOM_STATE)
    pipeline.fit(X_train, y_train)
    _test_scores = evaluate_model_on_test(pipeline, X_test, y_test)

    # Hyperparameter tuning using RandomizedSearchCV
    clf = RandomForestClassifier(random_state=RANDOM_STATE)
    param_grid = {
        "model__criterion": ["gini", "entropy"],
        "model__max_depth": [None, 5, 10, 15, 20],
        "model__n_estimators": scipy.stats.randint(100, 500),
        "model__min_samples_split": [2, 5, 10],
        "model__min_samples_leaf": [1, 2, 4],
    }

    randomized_search_cv = StratifiedKFold(n_splits=CV_FOLDS, shuffle=True, random_state=RANDOM_STATE + 1)
    randomized_search = RandomizedSearchCV(
        create_pipeline_from_classifier(clf),
        param_grid,
        n_iter=25,
        cv=randomized_search_cv,
        scoring="roc_auc",
        verbose=1,
        n_jobs=-1,
    )
    randomized_search.fit(X_train, y_train)
    cv_df = pl.DataFrame(randomized_search.cv_results_).sort("rank_test_score")
    print(
        f"Randomized search CV - Cross-validated ROC-AUC score: {cv_df['mean_test_score'][0]:.4f} ± {cv_df['std_test_score'][0]:.4f}"
    )
    _cv_scores = validate_model(randomized_search.best_estimator_, X_train, y_train, CV_FOLDS, RANDOM_STATE)
    print(randomized_search.best_params_)
    _test_scores = evaluate_model_on_test(randomized_search.best_estimator_, X_test, y_test)

    # Hyperparameter tuning using Optuna
    def objective(trial: optuna.Trial) -> float:
        clf = RandomForestClassifier(
            criterion=trial.suggest_categorical("criterion", ["gini", "entropy"]),  # type: ignore
            max_depth=trial.suggest_int("max_depth", 5, 25, step=5),
            n_estimators=trial.suggest_int("n_estimators", 100, 500, step=50),
            min_samples_split=trial.suggest_categorical("min_samples_split", [2, 5, 10]),
            min_samples_leaf=trial.suggest_categorical("min_samples_leaf", [1, 2, 4]),
            random_state=RANDOM_STATE,
        )
        pipeline = create_pipeline_from_classifier(clf)
        scores = cross_val_score(
            pipeline,
            X_train,
            y_train,
            cv=StratifiedKFold(n_splits=CV_FOLDS, shuffle=True, random_state=RANDOM_STATE + 1),
            scoring="roc_auc",
            n_jobs=-1,
        )
        return scores.mean()

    optuna.logging.set_verbosity(optuna.logging.WARNING)
    study = optuna.create_study(direction="maximize")
    study.optimize(objective, n_trials=25)

    print("Best hyperparameters found:")
    for key, value in study.best_params.items():
        print(f"  {key}: {value}")
    best_clf = RandomForestClassifier(
        **study.best_params,
        random_state=RANDOM_STATE,
    )
    best_pipeline = create_pipeline_from_classifier(best_clf)
    _cv_scores = validate_model(best_pipeline, X_train, y_train, CV_FOLDS, RANDOM_STATE)
    best_pipeline.fit(X_train, y_train)
    _test_scores = evaluate_model_on_test(best_pipeline, X_test, y_test)


if __name__ == "__main__":
    main()
