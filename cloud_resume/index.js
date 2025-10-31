console.log("index.js file has started executing!");
const counter = document.querySelector(".counter-number");

async function updatecounter() {
    let response = await fetch("https://hgtgryyrsfeoiitfwcsx3iyp7q0lkmtg.lambda-url.eu-north-1.on.aws/");
    
    let data = await response.text(); 
    counter.innerHTML = `👁️️ Views: ${data.trim()}`; // Use .trim() to be safe
}

updatecounter();
