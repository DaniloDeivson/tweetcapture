from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64
import os
import uuid
import shutil

# Attempt to import TweetCapture. 
# Depending on how the package is structured/run, it might be a direct import or packaged.
try:
    from tweetcapture import TweetCapture
except ImportError:
    from screenshot import TweetCapture

app = FastAPI()

class CaptureRequest(BaseModel):
    tweet_url: str

@app.get("/capture")
async def capture_get(tweet_url: str):
    return await process_capture(tweet_url)

@app.post("/capture")
async def capture_post(request: CaptureRequest):
    return await process_capture(request.tweet_url)

async def process_capture(tweet_url: str):
    filename = f"tmp_{uuid.uuid4()}.png"
    try:
        tweet = TweetCapture()
        # The mode=3 (default) captures everything. 
        # night_mode=0 (default) is light mode.
        try:
            path = await tweet.screenshot(tweet_url, filename, mode=3, night_mode=0)
        except Exception as e:
             # If screenshot fails, it raises Exception
             raise HTTPException(status_code=400, detail=f"Failed to capture tweet: {str(e)}")
        
        if not os.path.exists(path):
             raise HTTPException(status_code=500, detail="Screenshot file was not created.")

        with open(path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
        
        # Cleanup
        os.remove(path)
        
        return {
            "tweet_url": tweet_url,
            "image_base64": encoded_string
        }
    except HTTPException as he:
        if os.path.exists(filename):
            os.remove(filename)
        raise he
    except Exception as e:
        if os.path.exists(filename):
            os.remove(filename)
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health():
    return {"status": "ok"}
