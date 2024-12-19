const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
const { project } = yargs(hideBin(process.argv)).argv;

// opens the url in the default browser
const launch = async () => {
    const open = (await import('open')).default;
    open('https://console.cloud.google.com/vertex-ai/publishers/google/model-garden/text-bison?project=' + project);

    open(
        'https://console.cloud.google.com/vertex-ai/colab/import/https:%2F%2Fraw.githubusercontent.com%2FGoogleCloudPlatform%2Fvertex-ai-samples%2Fmain%2Fnotebooks%2Fcommunity%2Fmodel_garden%2Fmodel_garden_pytorch_owlvit.ipynb?project=' +
            project
    );

    // specify the app to open in
    open(
        'https://console.cloud.google.com/vertex-ai/pipelines/vertex-ai-templates/bert-finetuning;versionId=sha256:0caf76450a3db5d768462d4846b4fb164845b0fc68383f6b4d7494be6bb7cf30/details?project=' +
            project
    );
};
launch();
