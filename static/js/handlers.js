import * as aes from './aes-gcm';
import { getWorkerJS } from './worker';

$(document).on('change', '.btn-file :file', function () {
    var input = $(this),
        numFiles = input.get(0).files ? input.get(0).files.length : 1,
        label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
    input.trigger('fileselect', [numFiles, label]);
});

$(document).ready(function () {
    let worker = new Worker(getWorkerJS());

    const buttons = $('button');
    const textArea = $('textarea');
    const rangeTime = $('#rangeTime');
    const formControlRange = $('#formControlRange');

    $('textarea').bind('input propertychange',
        function () {
            const val = $(this).val();
            if (val && val.length > 9) {
                buttons.removeAttr('disabled');
                formControlRange.removeAttr('disabled');
            }
            else {
                buttons.attr('disabled', true);
                formControlRange.attr('disabled', true);
            }
        });

    $('.btn-file :file').on('fileselect', function (event, numFiles, label) {
        const input = $(this).parents('.input-group').find(':text');
        if (input.length) {
            input.val(label);
            textArea.attr('disabled', false);
            if (textArea.val()) {
                if (!worker)
                    worker = new Worker(getWorkerJS());
                buttons.removeAttr('disabled');
                formControlRange.removeAttr('disabled');
            }
        } else {
            if (label) alert(label);
        }
    });

    formControlRange.on('change', function (event) {
        rangeTime.text(event.target.value);
    });

    $("#encrypt").button().click(async function () {
        const password = textArea.val();
        const file = document.getElementById('fileinput').files[0];
        let name = aes.getFileName(file.name);

        const salt = window.crypto.getRandomValues(new Uint8Array(8));
        const pepper = window.crypto.getRandomValues(new Uint8Array(8));
        const iv = window.crypto.getRandomValues(new Uint8Array(32));

        const importedPassKey = await aes.importKeyPBKDF2(password);
        const rawPasswordKey = await aes.deriveKey(importedPassKey, salt, ["encrypt"]);
        const oppsKey = await aes.deriveKey(importedPassKey, pepper, ["encrypt"]);

        aes.encryptMessage(rawPasswordKey, aes.convertStringToUintArray(name), iv)
            .then(function (ab) {

                const encryptedContentArr = new Uint8Array(ab);
                const buff = new Uint8Array(
                    salt.byteLength + encryptedContentArr.byteLength
                );
                buff.set(salt, 0);
                buff.set(encryptedContentArr, salt.byteLength);

                aes.encryptMessage(oppsKey, buff, iv)
                    .then(function (ab2) {
                        name = aes.arrayBufferToBase64(ab2);

                        $.ajax({
                            type: 'POST',
                            url: `${PRODUCTION ? EC2_API : DEV_SERVER}/${API_VERSION}/encrypt`,
                            contentType: "application/json",
                            dataType: 'json',
                            data: JSON.stringify({
                                name,
                                password,
                                expiration: rangeTime.text() * 3600,
                                iv: aes.arrayBufferToBase64(iv),
                                salt: aes.arrayBufferToBase64(pepper)
                            }),
                            success: function (res2) {
                                if (res2) {
                                    worker.onmessage = function (evt) {
                                        if (evt.data && evt.data.error) {
                                            alert('Encryption failed.');
                                            return;
                                        }
                                        aes.download(
                                            evt.data,
                                            name.replaceAll('/', '_'),
                                            file.type)
                                    };
                                    worker.postMessage([file, iv, rawPasswordKey, true]);
                                }
                            }
                        })
                    });
            });
    })

    $("#decrypt").button().click(function () {
        const password = textArea.val();
        const file = document.getElementById('fileinput').files[0];
        const name = aes.getFileName(file.name).replaceAll('_', '/');

        $.ajax({
            type: 'POST',
            url: `${PRODUCTION ? EC2_API : DEV_SERVER}/${API_VERSION}/decrypt`,
            contentType: "application/json",
            dataType: 'json',
            data: JSON.stringify({
                password,
                name
            }),
            success: function (res) {
                if (res) {
                    const iv = aes.base64ToArrayBuffer(res.iv);
                    const pepper = aes.base64ToArrayBuffer(res.salt);

                    aes.importKeyPBKDF2(password).then(function (pk) {

                        aes.deriveKey(pk, pepper, ["decrypt"]).then(function (passwordKey) {

                            const encryptedDataBuff = aes.base64ToArrayBuffer(res.name);

                            aes.decryptMessage(passwordKey, encryptedDataBuff, iv).then(function (decrDataBuff) {

                                const salt = decrDataBuff.slice(0, 8);
                                aes.deriveKey(pk, salt, ["decrypt"]).then(function (aesKey) {

                                    const encName = decrDataBuff.slice(8);
                                    aes.decryptMessage(aesKey, encName, iv).then(function (decr) {
                                        worker.onmessage = function (evt) {
                                            if (evt.data && evt.data.error) {
                                                alert('Decryption failed. Wrong password or corrupted file.');
                                                return;
                                            }
                                            aes.download(evt.data, aes.convertUintArraytoString(decr), file.type);
                                        };
                                        worker.postMessage([file, iv, aesKey, false]);
                                    })
                                });
                            });
                        });
                    });
                }
            }
        })
    });
});
