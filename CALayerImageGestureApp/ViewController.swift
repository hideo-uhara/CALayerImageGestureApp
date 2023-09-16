//
// ViewController.swift
//

import Cocoa

class ViewController: NSViewController {
	var layer: CALayer! = nil
	var transform: CATransform3D = CATransform3DIdentity
	var magnificationTransform: CATransform3D = CATransform3DIdentity
	var panTransform: CATransform3D = CATransform3DIdentity
	var rotateTransform: CATransform3D = CATransform3DIdentity
	
	@IBOutlet var scaleView: NSView!
	@IBOutlet var clickGestureRecognizer: NSClickGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.scaleView.wantsLayer = true
		
		self.clickGestureRecognizer.numberOfClicksRequired = 2 // double click
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		if self.layer == nil {
			self.layer = CALayer()
			self.layer.borderWidth = 1.0
			
			let image: NSImage = NSImage(named: "sample.jpeg")!
			
			self.layer.frame = self.scaleView.frame
			self.layer.masksToBounds = true
			self.layer.speed = 100.0
			self.layer.contents = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
			self.layer.contentsScale = self.view.window!.backingScaleFactor
			self.layer.contentsGravity = .resizeAspect
			self.layer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
			
			self.scaleView.layer?.addSublayer(self.layer)
		}
	}
	
	override var representedObject: Any? {
		didSet {
		}
	}
	
	@IBAction func magnificationGestureAction(_ sender: NSMagnificationGestureRecognizer) {
		
		self.layer.autoresizingMask = [] // autoresizeなしに設定(contentsGravity = .resizeAspectが効かない状態)
		
		let scale: CGFloat = 1.0 + sender.magnification
		
		self.magnificationTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, scale) // 拡大/縮小
		self.layer.transform = self.transform
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.magnificationTransform)
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.panTransform)
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.rotateTransform)
		
		if sender.state == NSGestureRecognizer.State.ended || sender.state == NSGestureRecognizer.State.cancelled {
			self.transform = CATransform3DConcat(self.transform, self.magnificationTransform)// 拡大/縮小を保持
			self.magnificationTransform = CATransform3DIdentity
		}
	}
	
	@IBAction func panGestureAction(_ sender: NSPanGestureRecognizer) {
		
		self.layer.autoresizingMask = [] // autoreizeなしに設定(contentsGravity = .resizeAspectが効かない状態)
		
		let point: CGPoint = sender.translation(in: self.view) // 移動した距離
		
		self.panTransform = CATransform3DTranslate(CATransform3DIdentity, point.x, self.scaleView.isFlipped ? -point.y : point.y, 0.0)
		self.layer.transform = self.transform
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.magnificationTransform)
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.panTransform)
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.rotateTransform)
		
		if sender.state == NSGestureRecognizer.State.ended || sender.state == NSGestureRecognizer.State.cancelled {
			self.transform = CATransform3DConcat(self.transform, self.panTransform) // 移動を保持
			self.panTransform = CATransform3DIdentity
		}
	}
	
	@IBAction func rotateGestureAction(_ sender: NSRotationGestureRecognizer) {
		
		self.layer.autoresizingMask = [] // autoreizeなしに設定(contentsGravity = .resizeAspectが効かない状態)
		
		self.rotateTransform = CATransform3DRotate(CATransform3DIdentity, sender.rotation, 0.0, 0.0, self.scaleView.isFlipped ? -1.0 : 1.0) // 回転
		
		self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5) // 中心
		
		self.layer.transform = self.transform
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.magnificationTransform)
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.panTransform)
		self.layer.transform = CATransform3DConcat(self.layer.transform, self.rotateTransform)
		
		if sender.state == NSGestureRecognizer.State.ended || sender.state == NSGestureRecognizer.State.cancelled {
			self.transform = CATransform3DConcat(self.transform, self.rotateTransform) // 回転を保持
			self.rotateTransform = CATransform3DIdentity
		}
	}
	
	
	@IBAction func doubleClickGestureAction(_ sender: NSClickGestureRecognizer) {
		
		// 拡大/縮小と移動がない状態にする
		self.layer.transform = CATransform3DIdentity
		self.transform = CATransform3DIdentity
		self.magnificationTransform = CATransform3DIdentity
		self.panTransform = CATransform3DIdentity
		self.rotateTransform = CATransform3DIdentity
		
		self.layer.frame = self.scaleView.frame
		self.layer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable] // autoresize有りに設定(contentsGravity = .resizeAspectが効く状態)
	}
	
}

extension ViewController: NSGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {
		return true // ジェスチャーを同時に認識
	}
}
