let searchButton = document.getElementById("search-button");
let chatBackbutton = document.getElementById("chatBackbutton");
let searchBackButton = document.getElementById("chat-back-button");
let searchScreen = document.getElementById("searchScreen");
let chatScreen = document.getElementById("chatScreen");
let homeScreen = document.getElementById("homeScreen");
let messageInput = document.getElementById("message-input");
let homeScreenMessagesBody = document.getElementById("homeScreenMessagesBody");
let searchScreenBody = document.getElementById("searchScreenBody");
let messages = [
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Abhishek Dana",
		count: 2,
		message: "Hey! how are you..",
		timeStamp: "Just Now"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Alpesh Dana",
		count: 4,
		message: "What are you doing?",
		timeStamp: "1 Min"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Neeraj Dana",
		count: 0,
		message: "Let talk tomorrow",
		timeStamp: "Yesterday"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Dheeraj Dana",
		count: 0,
		message: "Dont Know",
		timeStamp: "Yesterday"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Himanshu Dana",
		count: 5,
		message: "Why are you not seeing",
		timeStamp: "23/04/2021"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Akash Verma",
		count: 2,
		message: "Hey! how are you..",
		timeStamp: "22/04/2021"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Vinu Yaday",
		count: 0,
		message: "Bye",
		timeStamp: "22/04/2021"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Anjali Yadav",
		count: 0,
		message: "Take care, And Have Fun",
		timeStamp: "22/04/2021"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "Michel Jackson",
		count: 0,
		message: "Come to my concert",
		timeStamp: "22/04/2021"
	},
	{
		image:
			"https://mir-s3-cdn-cf.behance.net/project_modules/2800_opt_1/dbc1dd99666153.5ef7dbf39ecee.jpg",
		name: "John Vinod",
		count: 12,
		message: "Will do work together",
		timeStamp: "15/04/2021"
	}
];
messages = messages.sort((a, b) => {
	if (a.timestamp > b.timestamp) return 1;
});
messages.forEach((message) => {
	// Main Element
	var main = document.createElement("div");
	main.id = "message";
	main.classList.add("home-screen-messages-message");

	//Image Element
	var img = document.createElement("img");
	img.src = message.image;

	// Added Image To Main
	main.appendChild(img);

	// MainContent Element
	var mainContent = document.createElement("div");
	mainContent.classList.add("home-screen-messages-message-content");

	// Main Content Top
	var mainContentTop = document.createElement("div");
	mainContentTop.classList.add("home-screen-messages-message-content-top");

	// Main Content Top h4
	var mainContentToph4 = document.createElement("h4");
	mainContentToph4.innerText = message.name;

	// Main Content Top Span
	var mainContentTopSpan = document.createElement("span");
	mainContentTopSpan.innerText = message.timeStamp;

	mainContentTop.appendChild(mainContentToph4);
	mainContentTop.appendChild(mainContentTopSpan);

	mainContent.appendChild(mainContentTop);

	// Main Content Bottom
	var mainContentBottom = document.createElement("div");
	mainContentBottom.classList.add("home-screen-messages-message-content-bottom");

	// Main Content Bottom H4
	var mainContentBottomh4 = document.createElement("h4");
	mainContentBottomh4.innerText = message.message;

	mainContentBottom.appendChild(mainContentBottomh4);

	if (message.count != 0) {
		var mainContentBottomSpan = document.createElement("span");
		mainContentBottomSpan.innerText = message.count;
		mainContentBottom.appendChild(mainContentBottomSpan);
	}

	mainContent.appendChild(mainContentBottom);
	main.appendChild(mainContent);
	homeScreenMessagesBody.appendChild(main);
});
let elementsArray = document.querySelectorAll("#message");

elementsArray.forEach(function (elem) {
	elem.addEventListener("click", function () {
		console.log("Clicked");
		homeScreen.style.display = "none ";
		chatScreen.style.display = "block ";
		searchScreen.style.display = "none ";
	});
});

chatBackbutton.addEventListener("click", function () {
	chatScreen.style.display = "none ";
	searchScreen.style.display = "none ";
	homeScreen.style.display = "block ";
});

messageInput.addEventListener("focus", function () {
	document.getElementById("typing").style.display = "flex";
});
messageInput.addEventListener("focusout", function () {
	document.getElementById("typing").style.display = "none";
});

searchButton.addEventListener("click", function () {
	searchScreen.style.display = "block ";
	chatScreen.style.display = "none ";
	homeScreen.style.display = "none ";
});
searchBackButton.addEventListener("click", function () {
	searchScreen.style.display = "none ";
	chatScreen.style.display = "none ";
	homeScreen.style.display = "block ";
});

messages.forEach((message) => {
	// Main Element
	var main = document.createElement("div");
	main.classList.add("search-screen-body-item");

	//Image Element
	var img = document.createElement("img");
	img.src = message.image;

	// Added Image To Main
	main.appendChild(img);

	// MainContent Element
	var mainContent = document.createElement("div");
	mainContent.classList.add("search-screen-body-item-content");

	// Main Content Top
	var mainContentTop = document.createElement("div");
	mainContentTop.classList.add("search-screen-body-item-content-top");

	// Main Content Top h4
	var mainContentToph4 = document.createElement("h4");
	mainContentToph4.innerText = message.name;

	// Main Content Top Span
	var mainContentTopSpan = document.createElement("span");
	mainContentTopSpan.innerText = message.timeStamp;

	mainContentTop.appendChild(mainContentToph4);
	mainContentTop.appendChild(mainContentTopSpan);

	mainContent.appendChild(mainContentTop);

	// Main Content Bottom
	var mainContentBottom = document.createElement("div");
	mainContentBottom.classList.add("search-screen-body-item-content-bottom");

	// Main Content Bottom p
	var mainContentBottomp = document.createElement("p");
	mainContentBottomp.innerText = message.message;

	mainContentBottom.appendChild(mainContentBottomp);

	if (message.count != 0) {
		var mainContentBottomSpan = document.createElement("span");
		mainContentBottomSpan.innerText = message.count;
		mainContentBottom.appendChild(mainContentBottomSpan);
	}

	mainContent.appendChild(mainContentBottom);
	main.appendChild(mainContent);
	searchScreenBody.appendChild(main);
});

function search_message() {
	let input = document.getElementById("searchInput").value;
	input = input.toLowerCase();
	let x = document.getElementsByClassName("search-screen-body-item");

	for (i = 0; i < x.length; i++) {
		if (!x[i].children[1].innerText.toLowerCase().includes(input)) {
			x[i].style.display = "none";
		} else {
			x[i].style.display = "flex";
		}
	}
}
