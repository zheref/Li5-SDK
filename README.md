iOS
=======

Add your API key
----------------

Set your Discover SDK API key before launching the video feed. Usually, it is
done in the AppDelegate file:

.. code-block:: swift

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Li5SDK.shared.config(apiKey: kLi5SDKApiKeyString, forApp: kLi5SDKAppNameString)
        return true
    }

}

Launch the video feed
---------------------

The video feed can be launched at any time, provided that the API key has been
set.

.. code-block:: swift

    func startLi5SDKPrimeTime() {
        Li5SDK.shared.present()
    }

Configuring the video feed
--------------------------

You can configure any of the options available in `options`.
Use it to change only the ones you want at any time before the presentation execution.

.. code-block:: swift

    Li5SDK.shared.options.appName = "Custom App Name"
    Li5SDK.shared.options.contentCTACaption = "see more"
    Li5SDK.shared.options.playbackProgressColor = UIColor.yellow
    Li5SDK.shared.options.extendablePlaybackProgressColor = UIColor.orange

Set an EOS logo and/or text
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A logo and a phrase is shown as an overlay when the EOS starts playing.
To do so, you can specify one or both through `options`:

.. code-block:: swift

    Li5SDK.shared.options.logoImage = UIImage(name: kEOSImageNameString)
    Li5SDK.shared.options.eosText = kEOSText
