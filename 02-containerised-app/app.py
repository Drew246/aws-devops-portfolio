from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <html>
        <head>
            <title>Andrew McCollin | DevOps Portfolio</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background-color: #0f1117;
                    color: #ffffff;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }
                .container {
                    text-align: center;
                }
                h1 { color: #FF9900; }
                p { color: #aaaaaa; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Andrew McCollin</h1>
                <p>AWS & DevOps Portfolio — Containerised App running on ECS Fargate</p>
            </div>
        </body>
    </html>
    '''

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)