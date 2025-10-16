(() => {
    'use strict'

    const urlParams = new URLSearchParams(window.location.search);
    const contestId = urlParams.get("contest_id") || "unspecified-contest";
    const API_BASE_URL = "https://dmml.dapagyi.dedyn.io";

    function fetchContestName() {
        return axios.post(`${API_BASE_URL}/contest-info`, { contest_id: contestId })
            .then(function (response) {
                return response.data.contest_name || contestId;
            })
            .catch(function (error) {
                console.error("Error fetching contest title:", error);
                return contestId;
            });
    }
    fetchContestName().then(title => {
        document.getElementById("leaderboard-title").textContent = title;
    });

    function fetchLeaderboard() {
        axios.post(`${API_BASE_URL}/top-submissions-per-user`, { contest_id: contestId })
            .then(function (response) {
                const submissions = response.data;
                const leaderboardBody = document.getElementById("leaderboard-body");

                leaderboardBody.innerHTML = '';
                submissions.forEach((submission, i) => {
                    const row = `<tr><td>${i + 1}.</td><td>${submission.display_name}</td><td>${submission.score.toFixed(4)}</td><td>${new Date(`${submission.timestamp}Z`).toLocaleString("hu-HU", { timeZone: "Europe/Budapest" })}</td></tr>`;
                    leaderboardBody.innerHTML += row;
                });
                if (submissions.length === 0) {
                    leaderboardBody.innerHTML = `<tr><td colspan="4" class="text-center">No submissions yet.</td></tr>`;
                }
                document.getElementById("last-updated").textContent = new Date().toLocaleString("hu-HU", { timeZone: "Europe/Budapest" });
            })
            .catch(function (error) {
                console.error("Error fetching leaderboard:", error);
            });
    }

    setInterval(fetchLeaderboard, 10_000);
    fetchLeaderboard();
})();