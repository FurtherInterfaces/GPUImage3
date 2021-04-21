import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet weak var renderView: RenderView!
    var camera:Camera!
    var operation:ToonFilterCompute!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
//            operation = BasicOperation(fragmentFunctionName: "passthroughFragment")
            operation = ToonFilterCompute()
            camera = try Camera(sessionPreset: .hd4K3840x2160)
            camera.runBenchmark = true
            camera --> operation --> renderView
            camera.startCapture()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else { return }
        operation.threshold = slider.value
    }
    
}

