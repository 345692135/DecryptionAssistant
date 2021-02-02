/*
 * @Author: hemingjin
 * @Date: 2021-02-01 10:56:41
 * @LastEditTime: 2021-02-01 10:56:49
 * @LastEditors: hemingjin
 * @Description: 
 * @FilePath: \js_excel\js\bridge.js
 * @可以输入预定的版权声明、个性签名、空行等
 */
//判断机型
let u = navigator.userAgent;

// ios注册事件监听
function setupWebViewJavascriptBridge(callback) { 
    if (/(iPhone|iPad|iPod|iOS)/i.test(u)) {  
        //IOS
        if (window.WebViewJavascriptBridge) {
            return callback(window.WebViewJavascriptBridge)
        }
        if (window.WVJBCallbacks) {
            return window.WVJBCallbacks.push(callback)
        }
        window.WVJBCallbacks = [callback]
        let WVJBIframe = document.createElement('iframe')
        WVJBIframe.style.display = 'none'
        WVJBIframe.src = 'https://__bridge_loaded__'
        document.documentElement.appendChild(WVJBIframe)
        setTimeout(() => {
            document.documentElement.removeChild(WVJBIframe)
        }, 0)
    }else {   
         // android
        if (window.WebViewJavascriptBridge) {
            callback(window.WebViewJavascriptBridge)
        } else {
            document.addEventListener(
                'WebViewJavascriptBridgeReady'
                , function() {
                    callback(window.WebViewJavascriptBridge)
                },
                false
            );
        }
        if (window.WVJBCallbacks) {
            return window.WVJBCallbacks.push(callback)
        }
    }
}
setupWebViewJavascriptBridge(function(bridge) {
    //初始化, ios设备不需要初始化！！！！！！！！
    if (!/(iPhone|iPad|iPod|iOS)/i.test(u)) { 
        bridge.init(function(message, responseCallback) {
            var data = { 'Javascript Responds': 'Wee!' }; 
            responseCallback(data);
        });
    }
})

const callHandler = (name, data, callback) =>{
    setupWebViewJavascriptBridge(function (bridge) { 
        bridge.callHandler(name, data, callback)
    })
}
const registerHandler = (name, callback) =>{
    setupWebViewJavascriptBridge(function (bridge) {
        bridge.registerHandler(name,
            function (data, responseCallback) { 
                callback(data, responseCallback)
            })
    })
} 
 