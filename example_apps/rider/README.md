# Running the example rider app

The easiest way to get started with the RideOsRider SDK is to build off of this example app. Here's how to get up and running.

## Install CocoaPods

If you don't already have CocoaPods installed, follow the instructions on their [homepage](https://cocoapods.org/) to install it. Once it is installed, run `pod install` from within the `example_apps/rider/ExampleRiderApp` directory and then open the generated `ExampleRiderApp.xcworkspace`.

## User authentication

To run any application that uses the RideOsRider SDK, you will need an Auth0 client ID and user database ID. We use Auth0 to authenticate users into our ridehail endpoints, and we don't currently support 3rd party authentication. Please register for a rideOS account [here](https://app.rideos.ai/) and then [contact our team](mailto:support@rideos.ai) to create the client and user database. In your email, please include the bundle ID of your app. In the future, this will be self-service.

Once you have the client and user database IDs, open `Auth0.plist` and change the `ClientId` property to match your client ID and the `UserDatabaseId` property to match your user database ID.

## Create a fleet

Before you start hailing rides, you'll need to create a fleet for your riders and drivers to operate on. The easiest way to do this is to grab your rideOS API key from [https://app.rideos.ai/profile](https://app.rideos.ai/profile). Once you have the API key, fill it into the following request, along with your intended fleet's ID.

```bash
curl -H "Content-Type: application/json" \
    -H "X-Api-Key: YOUR_API_KEY" \
    --data '{"id": "YOUR_FLEET_ID"}' \
    https://api.rideos.ai/ride-hail-operations/v1/CreateFleet
```
Note that you only need to run this command once, even if you're building both a rider and a driver app, and that you should use the same fleet ID for both apps.

Then, open `Info.plist` and change the value of the `DefaultFleetID` to match your chosen fleet ID. 

## Google Maps

By default, the example rider app uses our Google Maps-based implementation of our mapping protocols, so you'll need a Google API key. You can get one by following [these instructions](https://developers.google.com/maps/documentation/ios-sdk/get-api-key). Once you have a Google API key, open `Info.plist` and replace the value of `GoogleAPIKey` with your Google API key.

## Running the app

With the requisite keys entered, you should be able to build and run the `ExampleRiderApp` target in XCode. You and your users will need to sign up for an account in the app, then login and begin requesting rides! Note that if you're running the app in the iOS Simulator, you'll need to simulate a location through XCode.

## Questions, comments?

If you have any questions or comments, don't hesitate to reach out on GitHub or via [email](mailto:support@rideos.ai). Our team is standing by to help!
