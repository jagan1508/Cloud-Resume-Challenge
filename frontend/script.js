async function getVisitorCount() {
    try {
        const response=await fetch ("https://YOUR_FUNCTION_APP.azurewebsites.net/api/visitorcount");
        const data=await response.json();
        document.getElementById("visitor-count").innerText = data.count ;
    }
    catch (error) {
        console.error("Error fetching visitor count:", error);
        document.getElementById("visitor-count").innerText = "Unavailable";
    }

    
}

getVisitorCount();  