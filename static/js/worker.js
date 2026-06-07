export function getWorkerJS() {
    const js = `
    onmessage = function (e) {
        var reader = new FileReaderSync();
        var buffer = reader.readAsArrayBuffer(e.data[0]);
    
        if(e.data[3]){
            crypto.subtle.encrypt(
                {
                    name: "AES-GCM",
                    iv: e.data[1]
                },
                e.data[2],
                buffer
            ).then(function(a){
                postMessage(a);
            }).catch(function(){
                postMessage({ error: true });
            });
        } else {
            crypto.subtle.decrypt(
                {
                    name: "AES-GCM",
                    iv: e.data[1]
                },
                e.data[2],
                buffer
            ).then(function(a){
                postMessage(a);
            }).catch(function(){
                postMessage({ error: true });
            });
        }
    };
    `;
    var blob = new Blob([js], { "type": "text/plain" });
    return URL.createObjectURL(blob);
};