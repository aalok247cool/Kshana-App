import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:confetti/confetti.dart';

class InstagramZonePage extends StatefulWidget {
  const InstagramZonePage({Key? key}) : super(key: key);

  @override
  _InstagramZonePageState createState() => _InstagramZonePageState();
}

class _InstagramZonePageState extends State<InstagramZonePage> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Timer related variables
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  bool _isTimerRunning = false;
  int _coinsEarned = 0;

  // Confetti controller for reward popup
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause the timer when app goes to background
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;

          // Add coins when timer completes
          _coinsEarned += 10; // Add 10 coins for 5 minutes of Instagram usage

          // Show reward popup
          _showRewardPopup();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _resumeTimer() {
    if (_isTimerRunning) {
      _startTimer();
    }
  }

  void _showRewardPopup() {
    // Play confetti animation
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Confetti effect above the popup
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.1,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ],
                  ),
                ),
                const Icon(
                  Icons.celebration,
                  color: Colors.amber,
                  size: 70,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You earned 10 Kshana Coins for spending time on Instagram!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    'Continue Browsing',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset timer for another 5 minutes
                    setState(() {
                      _remainingSeconds = 300;
                      _startTimer();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _reloadWebView() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri('https://www.instagram.com/')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Show error widget if there's an error
                  if (_hasError)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red),
                          SizedBox(height: 20),
                          Text('Unable to load Instagram', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          Text(_errorMessage, textAlign: TextAlign.center),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _reloadWebView,
                            child: Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  else
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri('https://www.instagram.com/'),
                        headers: {
                          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
                          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                          'Accept-Language': 'en-US,en;q=0.9',
                        },
                      ),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          javaScriptEnabled: true,
                          mediaPlaybackRequiresUserGesture: false,
                          useOnDownloadStart: true,
                          userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
                          cacheEnabled: true,
                          clearCache: false,
                          preferredContentMode: UserPreferredContentMode.MOBILE,
                          supportZoom: false,
                          verticalScrollBarEnabled: false,
                          horizontalScrollBarEnabled: false,
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          domStorageEnabled: true,
                          databaseEnabled: true,
                          supportMultipleWindows: false,
                          builtInZoomControls: false,
                          displayZoomControls: false,
                          loadWithOverviewMode: true,
                          useWideViewPort: false,
                          forceDark: AndroidForceDark.OFF,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsBackForwardNavigationGestures: true,
                          isFraudulentWebsiteWarningEnabled: false,
                          allowsLinkPreview: false,
                          disableLongPressContextMenuOnLinks: true,
                        ),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        _webViewController = controller;

                        // Add JavaScript to help bypass detection
                        controller.evaluateJavascript(source: """
                          (function() {
                            // Override WebView detection properties
                            Object.defineProperty(navigator, 'webdriver', {
                              get: function() { return false; }
                            });
                            
                            // Hide any elements that might block the view
                            var style = document.createElement('style');
                            style.textContent = `
                              .dialog-container { display: none !important; }
                              .update-your-browser { display: none !important; }
                              .unsupported-browser { display: none !important; }
                              .app-download-interstitial { display: none !important; }
                            `;
                            document.head.appendChild(style);
                          })();
                        """);
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                      },
                      onLoadStop: (controller, url) {
                        setState(() {
                          _isLoading = false;

                          // Start the timer when the page finishes loading
                          if (!_isTimerRunning) {
                            _startTimer();
                          }
                        });

                        // Inject JS to bypass "browser not supported" screens
                        controller.evaluateJavascript(source: """
                          (function() {
                            // Hide any elements related to browser detection
                            var elementsToHide = document.querySelectorAll('.dialog-container, .update-your-browser, .unsupported-browser, .app-download-interstitial');
                            elementsToHide.forEach(function(element) {
                              element.style.display = 'none';
                            });
                            
                            // Force mobile view if needed
                            document.querySelector('meta[name="viewport"]').content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                          })();
                        """);
                      },
                      onLoadError: (controller, url, code, message) {
                        setState(() {
                          _isLoading = false;
                          _hasError = true;
                          _errorMessage = "Error $code: $message";
                        });
                        print("WebView Error: $code - $message");
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        var uri = navigationAction.request.url;
                        if (uri.toString().contains('instagram://') ||
                            uri.toString().contains('intent://instagram')) {
                          return NavigationActionPolicy.CANCEL;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print("Console: ${consoleMessage.message}");
                      },
                    ),

                  // Loading indicator
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                  // Timer display - positioned lower on screen
                  Positioned(
                    top: 80, // Moved down from the top
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Coins display - positioned lower on screen
                  Positioned(
                    top: 80, // Moved down from the top
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$_coinsEarned',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}