console.log("index.js file has started executing!");
const counter = document.querySelector(".counter-number");

async function updatecounter() {
    let response = await fetch("https://cvalrn2zkaakxkjq5u5dc523w40xktnj.lambda-url.us-east-2.on.aws/");
    
    // CHANGE: Use .text() instead of .json()
    let data = await response.text(); 
    
    // The data is now the string "4"
    counter.innerHTML = `👁️️ Views: ${data.trim()}`; // Use .trim() to be safe
}

updatecounter();