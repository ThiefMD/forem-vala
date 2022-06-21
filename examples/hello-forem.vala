public class HelloForem {
    public static int main (string[] args) {
        string user = "user";
        string password = "api-key";

        try {
            Forem.Client client = new Forem.Client ();
            string access_token;
            if (client.authenticate (
                    user,
                    password))
            {
                print ("Successfully logged in\n");
            } else {
                print ("Could not login");
                return 0;
            }

            string my_username;
            if (client.get_authenticated_user (out my_username)) {
                print ("Logged in as: %s\n", my_username);
            }

            string url;
            string id;
            if (client.publish_post (
                out url,
                out id,
                "# Hello Forem!

Hello from [ThiefMD](https://thiefmd.com)!",
                "Hello Forem!"))
            {
                print ("Made post: %s\n", url);
            }
        } catch (Error e) {
            warning ("Failed: %s", e.message);
        }
        return 0;
    }
}