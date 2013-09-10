# MoPub iOS SDK

Thanks for taking a look at MoPub! We take pride in having an easy-to-use, flexible monetization solution that works across multiple platforms.

Sign up for an account at [http://app.mopub.com/](http://app.mopub.com/).

Help is available on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started), detailed class documentation is available at [ClassDocumentation](http://htmlpreview.github.com/?https://github.com/mopub/mopub-ios-sdk/blob/master/ClassDocumentation/index.html)

[**Please see below to learn about recent changes to how Third Party Ad Network integrations are implemented**](#changes-to-third-party-ad-network-integrations)

## Download

The MoPub SDK is distributed as source code that you can include in your application.  MoPub provides two prepackaged archives of source code:

- **[MoPub Full SDK.zip](https://s3.amazonaws.com/mopub-ios-sdk/mopub-full.zip)**

  Includes everything you need to serve HTML and MRAID MoPub advertisiments *and* built-in support for three major third party ad networks - [iAd](http://advertising.apple.com/), [Google AdMob](http://www.google.com/ads/admob/), and [Millennial Media](http://www.millennialmedia.com/) - including the required third party binaries.

- **[MoPub Base SDK.zip](https://s3.amazonaws.com/mopub-ios-sdk/mopub-base.zip)**

  Includes everything you need to serve HTML and MRAID MoPub advertisements.  No third party ad networks are included.

The current version of the SDK is 1.12.1.0

## Integrate

Integration instructions are available on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started).

More detailed class documentation is available in the repo under the `ClassDocumentation` folder.  This can be viewed [online too](http://htmlpreview.github.com/?https://github.com/mopub/mopub-ios-sdk/blob/master/ClassDocumentation/index.html).


## New in this Version

Please view the [changelog](https://github.com/mopub/mopub-ios-sdk/blob/master/CHANGELOG.md) for details.

### Changes to Third Party Ad Network Integrations
**Important**: As of version 1.12.0.0 all third party ad network integrations are now implemented as custom events instead of adapters.

>  Please remove any old adapters from your code and use the new custom events located in the `AdNetworkSupport` folder instead.

More information can be found on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started#adding-third-party-ad-networks).


## Requirements

iOS 4.3 and up

## License

The MoPub iOS SDK is open sourced under the New BSD license:

Copyright (c) 2013 MoPub Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of MoPub nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.