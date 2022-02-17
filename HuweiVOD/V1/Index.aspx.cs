using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HuweiVOD.Services;
using Newtonsoft.Json;

namespace HuweiVOD.V1
{
    public partial class Index : System.Web.UI.Page
    {
        protected Credential credential = new Services.Credential();
        protected string security_token = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            credential = new Credential()
            {
                access = "",
                secret = "",
                securitytoken = ""
            };
            ApiService apiService = new ApiService("");
            credential = apiService.GetToken();
            if (credential == null)
            {
                credential = new Credential();
            }
        }
    }
}