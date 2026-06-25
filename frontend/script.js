    async function getVisitorCount() {
        try {
            const response=await fetch ("https://counter-functionapparc.azurewebsites.net/visitors-count");
            const data=await response.json();
            document.getElementById("visitor-count").innerText = data.visitors_count ;
        }
        catch (error) {
            console.error("Error fetching visitor count:", error);
            document.getElementById("visitor-count").innerText = "Unavailable";
        }

        
    }

    getVisitorCount();  