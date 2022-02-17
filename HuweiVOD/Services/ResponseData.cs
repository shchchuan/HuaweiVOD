using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace HuweiVOD.Services
{
    public class ResponseData
    {
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public int status { get; set; }
        /// &lt;summary&gt;
        /// 操作成功
        /// &lt;/summary&gt;
        public string message { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public CredentialData data { get; set; }
    }
    //如果好用，请收藏地址，帮忙分享。
    public class Credential
    {
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public string expiresAt { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public string access { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public string secret { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public string securitytoken { get; set; }
    }

    public class CredentialData
    {
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public Credential credential { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public string httpBody { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public int httpStatusCode { get; set; }
        /// &lt;summary&gt;
        /// 
        /// &lt;/summary&gt;
        public string httpHeaders { get; set; }
    }
}