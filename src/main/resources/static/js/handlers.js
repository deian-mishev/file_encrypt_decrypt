$(document).on('change', '.btn-file :file', function () {
    var input = $(this),
        numFiles = input.get(0).files ? input.get(0).files.length : 1,
        label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
    input.trigger('fileselect', [numFiles, label]);
});

$(document).ready(function () {
    const worker = new Worker(getWorkerJS());

    $('textarea').bind('input propertychange',
        function () {
            if ($(this).val()) {
                $('button').removeAttr('disabled');
            }
            else {
                $('button').attr('disabled', true);
            }
        });

    $('.btn-file :file').on('fileselect', function (event, numFiles, label) {
        var input = $(this).parents('.input-group').find(':text'),
            log = numFiles > 1 ? numFiles + ' files selected' : label;

        if (input.length) {
            input.val(log);
            $('textarea').attr('disabled', false);
        } else {
            if (log) alert(log);
        }
    });

    let iv;
    let hashedPassword;

    $("#encrypt").button().click(function () {
        const password = document.getElementById('textArea').value;
        iv = window.crypto.getRandomValues(new Uint8Array(32));
        const file = document.getElementById('fileinput').files[0];
        const name = file.name.split('.').slice(0, -1).join('.').replaceAll(' ', '_');
        const type = file.type;

        // $.ajax({
        //     type: 'POST',
        //     url: '/v1/encrypt',
        //     contentType: "application/json",
        //     dataType: 'json',
        //     data: JSON.stringify({
        //         name,
        //         password,
        //         iv
        //     }),
        //     success: res => {

        hashedPassword = password;
        importKey(hashedPassword, ["encrypt", "decrypt"]).then(key => {
            encryptMessage(key, name, iv)
                .then(arrayBuffer => {
                    base64Name = arrayBufferToBase64(arrayBuffer);
                    worker.onmessage = (evt) => {
                        download(evt.data, base64Name, type)
                    };

                    importKey(hashedPassword, ["encrypt", "decrypt"]).then(key => {
                        worker.postMessage([file, iv, key, true]);
                    })
                });
        });

        // }
        // })
    });

    $("#decrypt").button().click(function () {
        const password = document.getElementById('textArea').value;
        const file = document.getElementById('fileinput').files[0];
        const name = file.name.split('.').slice(0, -1).join('.');
        const type = file.type;

        // $.ajax({
        //     type: 'POST',
        //     url: '/v1/decrypt',
        //     contentType: "application/json",
        //     dataType: 'json',
        //     data: JSON.stringify({
        //         name: file,
        //         password
        //     }),
        //     success: res => {
        importKey(hashedPassword, ["encrypt", "decrypt"]).then(key => {
            decryptMessage(key, name, iv).then(decr => {
                worker.onmessage = (evt) => {
                    download(evt.data, decr, type)
                };
                worker.postMessage([file, iv, key, false]);
            })
        })
        //     }
        // })
    });
});
