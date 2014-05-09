package {
	import com.adobe.serialization.json.JSON;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.media.Microphone; 
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	import flash.events.SampleDataEvent;
	import fr.kikko.lab.ShineMP3Encoder;
	
	
	/**
	 * Simple sound recorder with upload
	 * @author jdudak
	 */
	public class Main extends Sprite {
		
		[Embed(source="../lib/glyphicons_300_microphone-2x.png")]
		public static var MicImage:Class;
		
		private static const APP_ID:String = "gz8Ep0q38TGdEJ7yAYcrGq1BE4YlinMGXQiE17J1";
		private static const API_KEY:String = "FlmN0gjsIjLUmdp85aIgBEAbp5REZsXAgPgWufhr";
		
		private var button:RecordButton;
		private var mic:Microphone;
		private var soundBytes:ByteArray;
		private var encoder:ShineMP3Encoder;
		
		public function Main():void {
			setupButton();
			setupMic();
		}
		
		private function setupMic():void {
			mic = Microphone.getMicrophone(); 
			mic.setSilenceLevel(0, 1000); 
			mic.gain = 50; 
			mic.rate = 44; 
			//mic.useEchoSuppression = true;
			mic.encodeQuality = 10;
		}
		
		private function setupButton():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.BOTTOM_LEFT;
			button = new RecordButton(20);
			this.addChild(button);
			button.addEventListener(MouseEvent.CLICK, buttonClicked);
		}
		
		private function buttonClicked(me:MouseEvent):void {
			switch (button.getState()) {
				case RecordButton.INITIAL_STATE:
					if (ExternalInterface.available) {
						ExternalInterface.call("window.audioRecordPermissionShow", null);
					}				
					mic.addEventListener(StatusEvent.STATUS, this.onMicStatus);
					mic.addEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler); 
					soundBytes = new ByteArray();
				case RecordButton.RECORD_STATE:
					soundBytes = new ByteArray();
					mic.addEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler); 
					button.setState(RecordButton.STOP_STATE);
					break;
				case RecordButton.STOP_STATE:
					mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler); 
					button.setState(RecordButton.PRELOAD_STATE);
					var waveBytes:ByteArray = new WaveEncoder(1).encode(soundBytes);
					encoder = new ShineMP3Encoder(waveBytes);
					encoder.addEventListener(Event.COMPLETE, onEncoded);
					encoder.start();
					break;
			}
		}
		
 
		private function onMicStatus(event:StatusEvent):void { 
			mic.removeEventListener(StatusEvent.STATUS, this.onMicStatus);
			if (ExternalInterface.available) {
				ExternalInterface.call("window.audioRecordPermissionHide", null);
			}	
			if (event.code == "Microphone.Unmuted") {
				button.setState(RecordButton.RECORD_STATE);
			}
		}
		
		private function micSampleDataHandler(event:SampleDataEvent):void { 
			while (event.data.bytesAvailable) { 
				var sample:Number = event.data.readFloat(); 
				//two channels, so write that twice
				soundBytes.writeFloat(sample); 
				soundBytes.writeFloat(sample);
			} 
		}
		
		private function onEncoded(e:Event):void {
			soundBytes = encoder.mp3Data;
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = "https://api.parse.com/1/files/audio.mp3";
			urlRequest.contentType =  "binary/octet-stream"; 
			urlRequest.method = URLRequestMethod.POST; 
			urlRequest.data = soundBytes;
			urlRequest.requestHeaders.push(new URLRequestHeader('Cache-Control', 'no-cache'));
			urlRequest.requestHeaders.push(new URLRequestHeader('X-Parse-Application-Id', APP_ID));
			urlRequest.requestHeaders.push(new URLRequestHeader('X-Parse-REST-API-Key', API_KEY));
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, uploadCompleted);
			urlLoader.load(urlRequest);
		}
		
		private function uploadCompleted(e:Event):void {
			if (ExternalInterface.available) {
				ExternalInterface.call("window.setAudioURL", JSON.decode(URLLoader(e.target).data).url);
			}
			//maybe save the returned url and change to play button
			button.setState(RecordButton.RECORD_STATE);
		}
		
	}
	
}