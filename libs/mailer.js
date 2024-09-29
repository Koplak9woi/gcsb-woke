const nodemailer = require('nodemailer');

const sendEmail = (username, password) => {
    const transporter = nodemailer.createTransport({
        service: 'Gmail',
        host: 'smtp.gmail.com',
        port: 465,
        secure: true,
        auth: {
            user: username,
            pass: password,
        },
    });

    const mailOptions = {
        from: username,
        to: username,
        subject: 'Map',
        text: 'See below',
    };

    return new Promise((resolve, reject) => {
        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error(error);
                console.log('Sending Email Failed, Retrying..');
                return sendEmail(username, password);
            } else {
                console.log('Email sent: ', info.response);
                resolve('Email sent: ', info.response);
            }
        });
    });
};

exports.sendEmail = sendEmail;
