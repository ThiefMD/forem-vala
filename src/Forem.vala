namespace Forem {
    public const string USER = "api/users/me";
    public const string NEW_POST = "api/articles";

    public class Client {
        public string endpoint = "https://dev.to/";
        private string? authenticated_user;
        private string? authenticated_user_id;
        private string? authenticated_user_url;

        public Client (string url = "") {
            if (url.chomp ().chug () != "") {
                string uri = url.chomp ().chug ();
                if (!uri.has_suffix ("/")) {
                    uri += "/";
                }
                endpoint = uri;
            }

            if (!endpoint.has_prefix ("http")) {
                endpoint = "https://" + endpoint;
            }

            authenticated_user = null;
        }

        public bool set_token (string auth_token) {
            authenticated_user = auth_token;
            string user;
            if (!get_authenticated_user (out user)) {
                authenticated_user = null;
                return false;
            }

            return true;
        }

        public bool publish_post (
            out string url,
            out string id,
            string content,
            string title,
            string series = "",
            string main_image = "",
            bool publish = false,
            string[]? tags = null,
            string canonical_url = "",
            string user_token = "")
        {
            string auth_token = "";
            url = "";
            id = "";
            bool published_post = false;
            if (user_token == "" && authenticated_user != null) {
                auth_token = authenticated_user;
            } else {
                auth_token = user_token;
            }

            PostArticle new_post = new PostArticle ();
            new_post.body_markdown = content;
            new_post.title = title;
            new_post.published = publish;
            if (canonical_url != "") {
                new_post.canonical_url = canonical_url;
            }
            if (main_image != "") {
                new_post.main_image = main_image;
            }
            if (series != "") {
                new_post.series = series;
            }
            if (tags != null && tags.length != 0) {
                new_post.tags = tags;
            }

            PostRequestData the_post = new PostRequestData ();
            the_post.article = new_post;

            Json.Node root = Json.gobject_serialize (the_post);
            Json.Generator generate = new Json.Generator ();
            generate.set_root (root);
            generate.set_pretty (false);
            // One day I'll find out how to do underscores...
            string request_body = generate.to_data (null).replace ("\"body-markdown\"", "\"body_markdown\"").replace ("\"main-image\"", "\"main_image\"").replace ("\"canonical-url\"", "\"canonical_url\"").replace ("\"organization-id\"", "\"organization_id\"");

            WebCall make_post = new WebCall (endpoint, NEW_POST);
            make_post.set_post ();
            make_post.set_body (request_body);
            if (auth_token != "") {
                make_post.add_header ("api-key", auth_token);
            }

            if (!make_post.perform_call ()) {
                warning ("Error: %u, %s", make_post.response_code, make_post.response_str);
                return false;
            }

            try {
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (make_post.response_str);
                Json.Node data = parser.get_root ();
                PostResponse response = Json.gobject_deserialize (
                    typeof (PostResponse),
                    data)
                    as PostResponse;

                if (response != null) {
                    published_post = true;
                    url = response.url;
                    id = response.id.to_string ();
                }
            } catch (Error e) {
                warning ("Unable to publish post: %s", e.message);
            }

            return published_post;
        }

        public bool get_authenticated_user (out string username, string user_token = "") {
            username = "";
            bool logged_in = false;
            string auth_token = "";
            if (user_token == "" && authenticated_user != null) {
                auth_token = authenticated_user;
            } else {
                auth_token = user_token;
            }

            if (auth_token == "") {
                return false;
            }

            WebCall authentication = new WebCall (endpoint, USER);
            authentication.set_get ();
            authentication.add_header ("api-key", auth_token);

            bool res = authentication.perform_call ();
            debug ("Got bytes: %d", res ? authentication.response_str.length : 0);

            if (!res) {
                warning ("Error %u: %s", authentication.response_code, authentication.response_str);
                return false;
            }

            try {
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (authentication.response_str);
                Json.Node data = parser.get_root ();
                MeResponse response = Json.gobject_deserialize (
                    typeof (MeResponse),
                    data)
                    as MeResponse;

                if (response != null) {
                    logged_in = true;
                    username = response.username;
                    authenticated_user = auth_token;
                    authenticated_user_id = response.id.to_string ();
                    authenticated_user_url = response.website_url;
                }
            } catch (Error e) {
                warning ("Unable to validate token: %s", e.message);
            }

            return logged_in;
        }

        public bool authenticate (
            string alias,
            string password,
            out string access_token) throws GLib.Error
        {
            string user = "";
            access_token = "";

            bool logged_in = get_authenticated_user (out user, password);

            if (logged_in) {
                access_token = password;
                authenticated_user = password;
            }

            return logged_in;
        }
    }

    public class Response : GLib.Object, Json.Serializable {
    }

    public class PostResponse : Response {
        public string type_of { get; set; }
        public int id { get; set; }
        public string title { get; set; }
        public string description { get; set; }
        public string cover_image { get; set; }
        public string readable_publish_date { get; set; }
        public string social_image { get; set; }
        public string tag_list { get; set; }
        public string[] tags { get; set; }
        public string slug { get; set; }
        public string path { get; set; }
        public string url { get; set; }
        public string canonical_url { get; set; }
        public int comments_count { get; set; }
        public int positive_reactions_count { get; set; }
        public int public_reactions_count { get; set; }
        public string created_at { get; set; }
        public string edited_at { get; set; }
        public string crossposted_at { get; set; }
        public string published_at { get; set; }
        public string last_comment_at { get; set; }
        public string published_timestamp { get; set; }
        public string body_html { get; set; }
        public string body_markdown { get; set; }
        public MeResponse user { get; set; }
        public int reading_time_minutes { get; set; }
        public OrgResponse organization { get; set; }
        public FlareResponse flare_tag { get; set; }
    }

    public class FlareResponse : Response {
        public string name { get; set; }
        public string bg_color_hex { get; set; }
        public string text_color_hex { get; set; }
    }

    public class OrgResponse : Response {
        public string name { get; set; }
        public string username { get; set; }
        public string slug { get; set; }
        public string profile_image { get; set; }
        public string profile_image_90 { get; set; }
    }

    public class MeResponse : Response {
        public string type_of { get; set; }
        public int id { get; set; }
        public string username { get; set; }
        public string name { get; set; }
        public string summary { get; set; }
        public string twitter_username { get; set; }
        public string github_username { get; set; }
        public string website_url { get; set; }
        public string location { get; set; }
        public string joined_at { get; set; }
        public string profile_image { get; set; }
        public string profile_image_90 { get; set; }
    }

    private class PostRequestData : GLib.Object, Json.Serializable {
        public PostArticle article { get; set; }
    }

    public class PostArticle : GLib.Object, Json.Serializable {
        public string title { get; set; }
        public string body_markdown { get; set; }
        public bool published { get; set; }
        public string series { get; set; }
        public string main_image { get; set; }
        public string canonical_url { get; set; }
        public string[] tags { get; set; }
        public int organization_id { get; set; }
    }

    private class WebCall {
        private Soup.Session session;
        private Soup.Message message;
        private string url;
        private string body;
        private bool is_mime = false;

        public string response_str;
        public uint response_code;

        public class WebCall (string endpoint, string api) {
            url = endpoint + api;
            session = new Soup.Session ();
            body = "";
        }

        public void set_body (string data) {
            body = data;
        }

        public void set_multipart (Soup.Multipart multipart) {
            message = Soup.Form.request_new_from_multipart (url, multipart);
            is_mime = true;
        }

        public void set_get () {
            message = new Soup.Message ("GET", url);
        }

        public void set_delete () {
            message = new Soup.Message ("DELETE", url);
        }

        public void set_post () {
            message = new Soup.Message ("POST", url);
        }

        public void add_header (string key, string value) {
            message.request_headers.append (key, value);
        }

        public bool perform_call () {
            MainLoop loop = new MainLoop ();
            bool success = false;
            debug ("Calling %s", url);

            add_header ("User-Agent", "forem-vala/0.1");
            if (body != "") {
                message.set_request ("application/json", Soup.MemoryUse.COPY, body.data);
            } else {
                if (!is_mime) {
                    add_header ("Content-Type", "application/json");
                }
            }

            session.queue_message (message, (sess, mess) => {
                response_str = (string) mess.response_body.flatten ().data;
                response_code = mess.status_code;

                if (response_str != null && response_str != "") {
                    debug ("Non-empty body");
                }

                if (response_code >= 200 && response_code <= 250) {
                    success = true;
                    debug ("Success HTTP code");
                }
                loop.quit ();
            });

            loop.run ();
            return success;
        }
    }
}
