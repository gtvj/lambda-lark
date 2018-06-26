const aws = require('aws-sdk');

const s3 = new aws.S3({ apiVersion: '2006-03-01' });

exports.handler = (event, context) => {

    console.log('Handler has been called');

    const bucket = event.Records[0].s3.bucket.name;
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
    const params = {
        Bucket: bucket + '-backup',
        CopySource: '/' + bucket + '/' + key,
        Key: key,
    };
    try {
        s3.copyObject(params, function(err, data) {
            if (err) console.log(err, err.stack);
            else console.log(data);
        })
    }
    catch (err) {
        console.log(err);
        const message = `Error getting object ${key} from bucket ${bucket}. Make sure they exist and your bucket is in the same region as this function.`;
        throw new Error(message);
    }
};
