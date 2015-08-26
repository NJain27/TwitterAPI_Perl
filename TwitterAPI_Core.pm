use strict;
use warnings;
use HTTP::Request::Common;
use HTTP::Headers;
use Net::SSL;
use LWP::UserAgent;
use Readonly;
use JSON qw( decode_json );
use open ':std', ':encoding(UTF-8)'; #UTF-8 encoding for wildcards and special characters

Readonly my $BEARER_TOKEN => "Basic YlJPeU41Z1ZTeFJ6eEFEcFVXU0Yxa3ZEZjpYZWN1eFY5TTJhTWQ2bm9GUmsxdVk4OFJEcDJlVWVMOGxRVmV0WkxWcWlPVlg0a2h0Vw=="; # Obtained from twitter after creating an app
Readonly my $TWITTER_API_URL => "https://api.twitter.com/";
Readonly my $TWITTER_OAUTH2_SUFFIX => "oauth2/token";
Readonly my $TWITTER_FRIENDSHIP => "1.1/friends/ids.json?screen_name=";
Readonly my $TWITTER_USER_TIMELINE => "1.1/statuses/user_timeline.json?screen_name=";
Readonly my $TWITTER_GET_USERS => "1.1/users/lookup.json?user_id=";    

my $accessToken = undef;
my $ua = LWP::UserAgent->new(ssl_opts=>{verify_hostname=>0},); # do not verify hostname when using Crypt::SSLeay

#Get Access Token From Twitter
sub getAccessToken()
{
    #If there's no accessToken, fetch it
    if (! defined $accessToken)
    {
        my $request = POST $TWITTER_API_URL.$TWITTER_OAUTH2_SUFFIX, 
		Content_Type =>'application/x-www-form-urlencoded;charset=UTF-8',
		Authorization => $BEARER_TOKEN,
		Content => [grant_type => 'client_credentials'];
        my $response = $ua->request($request);
        if ($response->is_success) {
            my $decoded = decode_json($response->decoded_content);
            $accessToken = $decoded ->{'access_token'};
        }
        else {
             die $response->code; 
        }
    }
    return $accessToken;
}

#Get latest tweets for given screen_name
sub getTweets{
    my ($username, $count) = @_;
    if (! defined $count || $count == 0){
        $count = 10; # Default limit to 10
    }
    elsif ($count > 200){
        $count = 200; # Limit recent tweets to 200
    }
    #If there's no accessToken, fetch it
    if (! defined $accessToken)
    {
        getAccessToken();
    }
    my @tweets;
    my $request = GET $TWITTER_API_URL.$TWITTER_USER_TIMELINE.$username.'&count='.$count, 
    Authorization => 'Bearer '.$accessToken; # Twitter requires Authorization in Header
    my $response = $ua->request($request);
    if ($response->is_success) {
        my $decoded = decode_json($response->decoded_content);
         foreach my $item (@$decoded) {
            push @tweets, $item ->{'text'}; # Push latest tweets to array
         }
    }
    else{
        die $response->code; # Throw exception if response is not 200
    }
    return @tweets;
}

# Get common user followed by both and get intersect
sub getIntersect{
    my ($username) = @_;
    my @usernames = split(',',$username); # Split usernames using , as delimiter
    if (scalar @usernames != 2) # Error out if not exactly 2 usernames are provided COMMA SEPARATED
    {
       die "Provide usernames";
    }
    #If there's no accessToken, fetch it
    if (! defined $accessToken)
    {
        getAccessToken();
    }
    my @ids;
    my @intersect;
    for (my $i=0; $i < 2; $i++) { # upper bound is 2 since we only find intersection between 2 users
        my $request = GET $TWITTER_API_URL.$TWITTER_FRIENDSHIP.$usernames[$i], 
        Authorization => 'Bearer '.$accessToken;  # Twitter requires Authorization in Header
        my $response = $ua->request($request);
        if ($response->is_success) {
            my $decoded = decode_json($response->decoded_content);
            my $iduser = $decoded ->{'ids'};
            push(@ids, @$iduser); # Push ids of all users followed by given user to array
        }
        else {
             die $response->code;  # Throw exception if response is not 200
        }
    }
    #Remove unique ids - only keep duplicates to get the intersection
    my %seen = ();
    my @dup = map { 1==$seen{$_}++ ? $_ : () } @ids;
    #Get list of ids of friends to fetch
    my $follows = join( ',', @dup);
    if (length $follows > 0)
    {
        my $request = GET $TWITTER_API_URL.$TWITTER_GET_USERS.$follows, 
        Authorization => 'Bearer '.$accessToken; # Twitter requires Authorization in Header
        my $response = $ua->request($request);
        if ($response->is_success) {
            my $decoded = decode_json($response->decoded_content);
            foreach my $item (@$decoded) {
               push @intersect, $item ->{'name'}; # push the username of the intersect ids fetched above
            }
        }
        else {
             die $response->code; # Throw exception if response is not 200
        }
    }
    else{
        die "No common user"; # Throw exception if no common users being followed
    }
    return @intersect;
}
