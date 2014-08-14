# 0.0.5
- Don't send the phrender header arbitrarily. Only send it when we're
  legitimately looking for a file for phrender.

# 0.0.4
- Don't blow up if there is no user-agent string when using rack middleware.
- Pass a 'phrender_request' header to upstream middleware.
