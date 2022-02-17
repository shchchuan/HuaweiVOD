using System;
using RestSharp;
using Newtonsoft.Json;
using System.Collections.Generic;
using Ch.Utility;

namespace HuweiVOD.Services
{
    /// <summary>
    /// 市场部通用接口
    /// </summary>
    public class ApiService
    {
        protected string apiUrl = $"https://hwcloudapi.chchuan.com/";
        protected string correlationId = string.Empty;
        public ApiService(string _correlationId)
        {
            correlationId = _correlationId;
        }
        /// <summary>
        /// 1.get token
        /// </summary>
        /// <returns></returns>
        public Credential GetToken()
        {
            RestClient client = new RestClient(apiUrl);
            var path = $"iam";
            var restRequest = new RestRequest(path, Method.GET);
            var response = client.Execute<ResponseData>(restRequest);
            Log.WriteLog("Token", response.Content);
            Log.WriteLog("Token", JsonConvert.SerializeObject(response.Data));
            return response.Data?.data?.credential;
        }
    }
}
