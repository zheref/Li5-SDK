Android
=======

The following will guide you through the Android Li5 SDK Installation process
via Gradle.

Add the SDK to Gradle
---------------------

TODO

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

Video feed callbacks
~~~~~~~~~~~~~~~~~~~~

If you specify a delegate `delegate` that implements `Li5SDKDelegate`,
you can get notified when the EOS starts:

Get notified when the EOS starts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The event `onStartEOS` lets you know if the episode has an EOP and/or an EOS;
in any case, this method is called when EOP has finished and the EOS is going
to start:

.. code-block:: java

@Override
public void onStartEOS(boolean hasEOP, boolean hasEOS) {
if (hasEOS) {
//...
} else {
//...
}
}

Change the "See More" text on a trailer
---------------------------------------

This text can be changed to anything. Usually, it should hint the user to
swipe up and see details about the video.

Add the next line in your `strings.xml` to change it:

.. code-block:: xml

<string name="trailer_hint_see_more">Buy It</string>

Trailer ProgressBar color
-------------------------

All trailers have a horizontal ProgressBar on the top. The color of it depends
on wether or not it has an extended video too.

Change the default colors for each case specifying one or both in your `colors.xml` file:

.. code-block:: xml

<?xml version="1.0" encoding="utf-8"?>
<resources>
<color name="has_full_video_progressbar_color">#303F9F</color>
<color name="only_trailer_progressbar_color">#FF4081</color>
</resources>
