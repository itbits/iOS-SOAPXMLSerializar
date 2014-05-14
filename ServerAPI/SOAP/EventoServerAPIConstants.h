/*Created by Muhammad Imran on 4/6/14. */


/**
 *  Base Server URL, We will use this constant to construct the URLs for web service requests
 */
#define kBaseServerURL                      @"http://213.42.55.45/"

/**
 *  This notification will be fired when the server is down and we try to access some web service.
 *  We need to handle this notification on any central place to show some alert message to user
 */
#define kCommonUnableToAccessServices       @"kCommonUnableToAccessServices"

/**
 * This notification will be fired on server time out.
 * We need to handle this notification on any central place to show some alert message to user
 */
#define kCommonSessionTimeout               @"kCommonSessionTimeout"

/**
 * This notification will fire on falioure to authinticate user.
 * We need to handle this notification on any central place to show some alert message to user
 */
#define kAuthorizationFailureNotification   @"kAuthorizationFailureNotification"

/**
 * This notification will be fired for any unhandled server side exception
 * We need to handle this notification on any central place to show some alert message to user
 */
#define kCommonUnexpectedServerError        @"kCommonUnexpectedServerError"
/**
 *  YES = Enabled (Request and response will be loged)
 *  NO  = Disabled (We will not log request and response data)
 */

#define kLogingEnabled                     NO


