# TwitterAPI_Perl
#**INSTALLATION GUIDE**

**The project contains 2 files:**
  1.	TwitterAPI_Core.pm (Core files to call Twitter APIs)
  2.	TwitterAPI_Web.pl (Web application using REST APIs)

Both the files should be present in the same directory.

**Pre-requisites to deploy and run the application:**

Latest perl edition and openssl should be installed.
In order to install the prerequisites, run cpan <module_name> (as mentioned below):
  1.	Mojolicious
  2.	HTTP::Request::Common
  3.	HTTP::Headers
  4.	Readonly
  5.	LWP::UserAgent
  6.	Crypt::SSLeay

**To deploy, run the following command:**

perl TwitterAPI_Web.pl daemon

**To try on public server, go to:**

http://54.201.18.204/ (hosted on AWS)



#**API DOCUMENTATION**

##**GET latesttweets**

Returns a collection of the most recent tweets posted by the user indicated by the screen_name, in a chronological order.
This method returns up to 200 of the user’s most recent tweets. These do not include retweets.

**URL:** /latesttweets

**Parameters:**	
  1. **Screen_name:** The screen_name of the user for whom to return the most recent tweets.
      1. **Example value:** njain27
      2. **Required:** YES

  2. **Count:** Number of the most recent tweets to return for the given user. 
      1. **Maximum:** 200	
      2. **Required:** NO 
      3. **Default:** 10.

**Example Request:**
/latesttweets?screen_name=njain27&count=5


##**GET followsintersection**

Returns a collection of the common users followed by the two user indicated by the screen_name.

**URL:** /followsintersection

**Parameters:** 
  1. **Screen_name:** The two screen_name of the users for whom to return the common friends.
      1. **Example value:** prateekgupta87,njain27
	  2. **Required:** YES. Exact two.

**Example Request:**
/ followsintersection?screen_name=prateekgupta87,njain27

**Adding more API methods:**
  1. Create a new method in TwitterAPI_Core.pm.
  2. If accessToken doesn’t exist, call method getAccessToken() to fetch accessToken
  3. Return result in JSON format
  4. Raise exception when the response is not 200 from Twitter API requests.
  5. Add another condition in the TwitterAPI_web.pl to specify URL action.
  6. Read the parameters and call the new method.
  7. Return JSON result and catch exception, if any.
  8. Read error string from the method getErrorString by passing Exception string as parameter.
  9. Add any new exception to the getErrorString method, to give user friendly error messages.



