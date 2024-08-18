from flask import Flask, request
import google.auth
from google.cloud import translate

app = Flask(__name__)
_, PROJECT_ID = google.auth.default()
TRANSLATE = translate.TranslationServiceClient()
PARENT = 'projects/{}'.format(PROJECT_ID)
SOURCE, TARGET = ('en', 'English'), ('es', 'Spanish')

@app.route('/', methods=['GET', 'POST'])
def index():
    # reset all variables
    text = translated = None

    if request.method == 'POST':
        text = request.get_json().get('text').strip()
        if text:
            data = {
                'contents': [text],
                'parent': PARENT,
                'target_language_code': TARGET[0],
            }
            # handle older call for backwards-compatibility
            try:
                rsp = TRANSLATE.translate_text(request=data)
            except TypeError:
                rsp = TRANSLATE.translate_text(**data)
            translated = rsp.translations[0].translated_text

    # create context
    context = {
        'trtext': translated
    }
    return context

if __name__ == "__main__":
    # Dev only: run "python main.py" and open http://localhost:8080
    import os
    app.run(host="localhost", port=int(os.environ.get('PORT', 8080)), debug=True)