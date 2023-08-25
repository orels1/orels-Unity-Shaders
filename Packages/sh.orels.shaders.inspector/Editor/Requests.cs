#if UNITY_2019_4
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Newtonsoft.Json;
using UnityEngine;

namespace ORL.ShaderInspector
{
    public static class Requests
    {
        private static Dictionary<string, (DateTime timestamp, object data)> _cache = new Dictionary<string, (DateTime, object)>();

        private static HttpClient _client;

        private static HttpClient Client
        {
            get
            {
                if (_client != null) return _client;
                var client = new HttpClient();
                client.DefaultRequestHeaders.Add("User-Agent", "ORL Shader Inspector ping at orels sh");

                _client = client;
                return _client;
            }
        }
        
        public static async Task<TResponse> Request<TResponse>(string requestUrl, HttpMethod method, Dictionary<string, string> queryParams = null, bool refetch = false)
        {
            var urlBuilder = new UriBuilder(requestUrl);
            if (queryParams != null)
            {
                var existingQuery = urlBuilder.Query.Length > 0 ? urlBuilder.Query.Substring(1) : "";
                urlBuilder.Query = existingQuery + "&" + (await (new FormUrlEncodedContent(queryParams).ReadAsStringAsync()));
            }

            var url = urlBuilder.Uri;
            Debug.Log($"requesting url {url.ToString()}");
            var cacheKey = method + ":" + url.ToString();
            var isCached = _cache.TryGetValue(cacheKey, out var cacheData);
            // 10 minute cache time
            isCached = isCached && DateTime.Now.Subtract(cacheData.timestamp).TotalMilliseconds < (1000 * 60 * 10);
            if (method == HttpMethod.Get)
            {
                if (isCached && !refetch)
                {
                    return (TResponse) cacheData.data;
                }
            } else if (isCached || refetch)
            {
                _cache.Remove(cacheKey);
            }

            var request = new HttpRequestMessage(method, url);
            var result = await Client.SendAsync(request);

            if (!result.IsSuccessStatusCode)
            {
                throw new Exception($"Failed to request data from {url.ToString()}");
            }

            var expectedType = typeof(TResponse);
            
            // return byte array if it is expected
            if (expectedType.IsArray && expectedType.GetElementType() == typeof(byte))
            {
                var bytes = await result.Content.ReadAsByteArrayAsync();
                if (method == HttpMethod.Get)
                {
                    _cache[cacheKey] = (DateTime.Now, bytes);
                }

                return (TResponse) (object) bytes;
            }

            var jsonString = await result.Content.ReadAsStringAsync();
            try
            {
                var deserialized = JsonConvert.DeserializeObject<TResponse>(jsonString, new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                });
                if (method == HttpMethod.Get)
                {
                    _cache[cacheKey] = (DateTime.Now, deserialized);
                }
                return deserialized;
            }
            catch (Exception)
            {
                throw;
            }
        }
        
        public static async Task<Texture2D> GetImage(string url, bool refetch = false)
        {
            var imageBytes = await Request<byte[]>(url, HttpMethod.Get, null, refetch);
            var image = new Texture2D(256, 256)
            {
                wrapMode = TextureWrapMode.Clamp
            };
            image.LoadImage(imageBytes);
            return image;
        }
    }
}
#endif