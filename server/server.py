from flask import Flask,request,jsonify
import os
import cv2
import tensorflow as tf
import numpy as np 
idx_to_class = {0:'क',1:'ख',2:'ग',3:'घ',4:'ङ',5:'च',6:'छ',7:'ज',8:'झ',9:'ञ',10:'ट',11:'ठ',12:'ड',13:'ढ',14:'ण',15:'त',16:'थ',17:'द',18:'ध',19:'न',20:'प',21:'फ',22:'ब',23:'भ',24:'म',25:'य',26:'र',27:'ल',28:'व',29:'श',30:'ष',31:'स',32:'ह',33:'क्ष',34:'त्र',35:'ज्ञ'}
app = Flask(__name__)
UPLOAD_FOLDER = r'C:\Users\user\Desktop\minor\server'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
@app.route('/api')
def hello_world():
    d= {}
    d['Query'] = 'server says :'+ str(request.args["Query"])
    return jsonify(d)

@app.route('/predict',methods=['POST'])
def predict():
    img = request.files['image']
    img.save(os.path.join(app.config['UPLOAD_FOLDER'], 'photo.png'))
    model = tf.keras.models.load_model('model.h5')
    img = cv2.imread(r'C:\Users\user\Desktop\minor\server\photo.png',cv2.IMREAD_GRAYSCALE)
    img = cv2.resize(img,(32,32))/255
    img = np.expand_dims(img,axis=-1)
    img = np.expand_dims(img, axis = 0)
    result = model.predict(img)
    return jsonify({'result':idx_to_class[np.argmax(result)]})

if __name__ == '__main__':
    app.run(debug=True,host='192.168.43.175',port=5000)