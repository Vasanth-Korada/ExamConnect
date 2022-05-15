const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

exports.announcementsTrigger = functions.firestore.document(
    'announcements/{id}'

).onCreate((snapshot, context) => {
    msgData = snapshot.data();

    return admin.firestore().collection('tokens').get().then((snapshots) => {
        const tokens = [];
        if (snapshots.empty) {
            console.log('No devices');
        } else {
            for (var token of snapshots.docs) {
                tokens.push(token.data().token);
            }
            const payload = {
                "notification": {
                    "title": "New Announcement!",
                    "body": msgData.title,
                    "sound": "default",
                    // "icon": "https://image.flaticon.com/icons/png/512/2419/2419224.png",
                },
                "data": {
                    "sendername": msgData.title,
                    "message": msgData.title
                }
            }
            admin.messaging().sendToDevice(tokens, payload).then((response) => {
                console.log('Pushed Notification to all the tokens');
                return null;

            }).catch((err) => {
                console.log(err);
            })
        }
        return null;
    })
})
