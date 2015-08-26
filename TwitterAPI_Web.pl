use strict;
use warnings;
use Mojolicious::Lite; #Web framework
use TwitterAPI_Core;
use Mojo::JSON qw(encode_json);
use open ':std', ':encoding(UTF-8)'; #UTF-8 encoding for wildcards and special characters

get '/' => {text => "For Documentation visit: <a href= \"https://github.com\/NJain27\/TwitterAPI_Perl\">Github Readme</a><br><br>
                     <strong>Supported APIs usage:</strong><br> 
                     latesttweets\\screen_name=[twitter_screen_name]&count=[upto_200,default:10][optional:count]<br>
                     followsintersection\\screen_name[twitter_screen_name1,twitter_screen_name2]"}; # display usage on homepage

get '/:action' => sub { #Implement a common url for API
    my $self = shift;
    my $user = $self->param('screen_name');
    my $count = $self->param('count');
    my $action = $self->stash('action');
    chomp $user;
    #Get latest tweets
    if ($action eq "latesttweets") # API latesttweets
    {
        if (length($user) == 0)
        {
            return $self->render (json => {error => getErrorString("Format exception", $user)}); #Error out if screen_name is not present
        }
        my @tweets;
        eval {
        @tweets = getTweets($user, $count);
        };
        if($@) {
            $self->render (json => {error => getErrorString($@, $user)}); #Check for any error present
        }
        else {
            $self->render (json => {screenname => $user, tweets => \@tweets});
        }
    }
    #Get common friends
    elsif ($action eq "followsintersection") #API followsintersection
    {
        if (length($user) == 0)
        {
            return $self->render (json => {error => getErrorString("Format exception", $user)}); #Error out if screen_name is not present
        }
        my @follows;
        eval{
            @follows = getIntersect($user);
        };
        if($@) {
            $self->render (json => {error => getErrorString($@, $user)});  #Check for any error present
        }
        else {
            $self->render (json => {screenname => $user, commonfollows => \@follows});
        }
    }
    #Not found.
    else{
        return $self->reply->exception("API ".$action." not implemented."); #Throw 501 if any other API name is given since they are not implemented
    }
};
#Get Error messages
sub getErrorString{ #Routine to check for known error messages
     my ($error, $user) = @_;
     #No user found.
    if (index($error, '404') != -1) {
        return $user." user does not exist in Twitter!";
    }
    #Rate limit exceeded.
    elsif (index($error, '403') != -1 || index($@, '429') != -1) {
        return "You've exceeded the rate limit of Twitter APIs. Please try again later (Preferably after 15 minutes)."
    }
    #Connection not established or Twitter service down.
    elsif (index($error, '500') != -1 || index($error, '502') != -1 || index($error, '503') != -1 || index($error, '504') != -1) {
        return "Something seems to be wrong at Twitter. Please contact administrator."
    }
    #Format Exception
    elsif(index($error, "Format exception") != -1){
        return "Proper usage: http://[hostname]/[api_name]/screen_name=[twitter_screen_name]&count=[ONLY FOR API latesttweets,upto_200,default:10][optional:count]";
    }
    #Exactly 2 usernames for API-followsintersection
    elsif(index($error, "Provide usernames") != -1){
        return "Provide exactly 2 comma seperated usernames.";
    }
    #No Common User
    elsif(index($error, "No common user") != -1){
        return "No common users followed by both.";
    }
    else{
    return $error;
    }
}
app->start;

#Template for exception
__DATA__

@@ exception.development.html.ep
<!DOCTYPE html>
<html>
  <head><title>Server error</title></head>
  <body>
    <h1>Exception</h1>
    <p><%= $exception->message %></p>
  </body>
</html>

@@ not_found.development.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>Server error</title>
    <meta http-equiv="refresh" content="5; url=http://54.201.18.204/" />
  </head>
  <body>
    <h1>Exception</h1>
    <p>404 - URL does not exist</p>
    <p>If you are not redirected automatically in 5 seconds, follow the <a href='http://54.201.18.204/'>link to homepage</a></p>
  </body>
</html>
