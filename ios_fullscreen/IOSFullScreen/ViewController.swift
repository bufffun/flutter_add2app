// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import Flutter

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
    }

    @IBAction func buttonWasTapped(_ sender: Any) {
        if let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine {
            let flutterViewController = FlutterViewControllerWrapper(engine: flutterEngine, nibName: nil, bundle: nil)
          self.navigationController?.pushViewController(flutterViewController, animated: true)
        }
    }
}

class FlutterViewControllerWrapper : FlutterViewController  {
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // simply deal with the pop case
    if let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine {
      flutterEngine.viewController = nil
    }
  }
}
