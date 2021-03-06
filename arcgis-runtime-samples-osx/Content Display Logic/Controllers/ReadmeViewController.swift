//
// Copyright 2016 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa
import WebKit

class ReadmeViewController: NSViewController {

    @IBOutlet private var webView:WebView!
    
    var folderName:String! {
        didSet {
            if self.folderName != nil {
                self.fetchFileContent(self.folderName)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchFileContent(folderName:String) {
        
        if let path = NSBundle.mainBundle().pathForResource("README", ofType: "md", inDirectory: folderName) {
            //read the content of the file
            if let content = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding) {
                //remove the images
                let pattern = "!\\[.*\\]\\(.*\\)"
                if let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive) {
                    let newContent = regex.stringByReplacingMatchesInString(content, options: NSMatchingOptions(), range: NSMakeRange(0, content.characters.count), withTemplate: "")
                    self.displayHTML(newContent)
                }
            }
        }
    }
    
    func displayHTML(readmeContent:String) {
        let cssPath = NSBundle.mainBundle().pathForResource("style", ofType: "css") ?? ""
        let string = "<!doctype html>" +
            "<html>" +
            "<head> <link rel=\"stylesheet\" href=\"\(cssPath)\">" +
            "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://cdnjs.cloudflare.com/ajax/libs/foundation/5.5.2/css/foundation.min.css\">" +
            "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css\">" +
            "</head>" +
            " <div id=\"preview\" sd-model-to-html=\"text\">" +
            "<div id=\"content\">" +
            "\(readmeContent)" +
            "</div></div>" +
            "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/showdown/1.1.0/showdown.js\"></script>" +
            "<script>" +
            "var conv = new showdown.Converter();" +
            "var txt = document.getElementById('content').innerHTML;" +
            "document.getElementById('content').innerHTML = conv.makeHtml(txt);" +
            "</script>" +
            "</body>" +
        "</html>"
        
        self.webView.mainFrame.loadHTMLString(string, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
    }
}
