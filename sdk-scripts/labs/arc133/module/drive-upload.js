const { google } = require('googleapis');
const { auth } = require('./auth');

const driveUpload = async (media, fileMetadata) => {
    const service = google.drive({ version: 'v3', auth });
    try {
        const file = await service.files.create({
            requestBody: fileMetadata,
            media: media,
            fields: 'id',
        });
        console.log('File Id:', file.data.id);
        return file.data.id;
    } catch (err) {
        throw err;
    }
};

exports.driveUpload = driveUpload;
