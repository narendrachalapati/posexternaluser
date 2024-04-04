// const form = document.getElementById("form");
// const inputFile = document.getElementById("file");

// const formData = new FormData();

// const handleSubmit = (event) => {
//     event.preventDefault();
//     formData.append('name', 'John Doe');
//     formData.append('email', 'john.doe@example.com');
//     for (const file of inputFile.files) {
//         formData.append("files", file);
//     }
    
//     console.log('fomr ', formData);

//     fetch("https://fhir-municorn.free.beeceptor.com/my/api/path", {
//         method: "post",
//         body: formData,
//     }).catch((error) => ("Something went wrong!", error));
// };

async function createContentVersion(url, sessionId, filedata, filename) {
    try{
        const formData = new FormData();
        console.log('sessionid ', sessionId);
        let entity_content = {
            ContentDocumentId:"",
            ReasonForChange: "",
            PathOnClient: filename
        }
        formData.append("entity_content", JSON.stringify(entity_content));
        
        // formData.append("entity_content", new Blob([JSON.stringify(entity_content)], {
        //     type: "application/json"
        // }));
        const base64Response = await fetch(filedata);
        const blob = await base64Response.blob();

        formData.append("VersionData", blob, "signature.png");
        // formData.append("VersionData", atob(filedata), "signature.png");
        url = url + '/services/data/v57.0/sobjects/ContentVersion';
        // url = 'https://fhir-municorn.free.beeceptor.com/my/api/path';
        fetch(url, {
            method: "POST",
            headers: {
                // 'Content-Type': 'multipart/form-data',
                'Authorization': 'Bearer ' + sessionId
            },
            body: formData,
        })
        .then(response => {
            console.log('response ', response);
            response.json();
        })
        .then(response => {
            console.log('file resp', JSON.stringify(response));
        })
        .catch((error) => {
            console.log("Something went wrong!", error);
        });
    } catch(e) {
        console.log('error ',e.message);
    }
    
}

function callJs(x) {
    console.log('xpress ',x);
}
