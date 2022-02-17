<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="HuweiVOD.V1.Index" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="IE=EDGE;chrome=1">
    <title>Vod 上传JS-SDK Demo</title>
    <link rel="stylesheet" type="text/css" href="./dist/indexStyle.css"/>
    <script src="./dist/jquery-3.3.1.min.js"></script>
    <script src="./dist/js-vod-sdk.min.js"></script>
    <script src="./js-obs/esdk-obs-browserjs-2.1.4.min.js"></script>

</head>
<body>
<div class="box">
    <H1>视频点播服务上传JS-SDK示例</H1>
    <div class="warnTip">提示：<br/>1、请先在对象存储服务(OBS)创建桶，并设置好桶的CORS；<br/> 2、文件上传结束后，请使用创建媒资-OBS转存接口生成媒资；<br/>3、详细请参考<a
            target="_blank" href="https://support.huaweicloud.com/csdk-vod/vod_06_0268.html">官网简介</a>。
    </div>

    <input placeholder="access(AK)" id="app_Key" class="form-control" value="<% =credential.access %>">
    <input placeholder="secret(SK)" id="app_Secret" class="form-control" value="<% =credential.secret %>">
    <input placeholder="security token" id="securityToken" class="form-control" value="<% =credential.securitytoken %>">
    <input placeholder="桶名" id="bucketName" class="form-control" value="vfile">
    <input placeholder="路径名(需要上传存放到OBS桶里的完整路径名，如：folder-1/video-HD.mp4)" id="filePath" class="form-control">
    <label for="MulitUploadFile" class="file">选择文件</label>
    <input id="MulitUploadFile" type="file"  multiple="multiple" placeholder="请选择文件" style="display: none;">
    <button class="file" onclick="cancelUpload()">取消</button>
    <button class="file" onclick="restartUpload()">续传</button>
    <input id="fileName" type="text" class="form-control" style="margin: 10px 0px;"/>
    <button onclick="uploadVideoFile()" class="file">开始上传</button>
    <br/>
    <!--进度条标签-->
    <div class = "progress-box">
        <div id="progress" class="progress-bar"></div>
        <span id="progress_num"></span>
    </div>
</div>
<script>

    var vodClient;

    /**
     * 上传视频方法
     */
    function uploadVideoFile() {
        if(!vodClient){
            var ak = $('#app_Key').val();
            var sk = $('#app_Secret').val();
            var securitytoken = $('#securityToken').val();
            var bucketName = $('#bucketName').val();
            var filePath = $('#filePath').val();
            $('#progress_num').html("0%");

            //创建vodClient实例 参数均为必填
            vodClient = new VodClient({
                "access_key_id": ak,
                "secret_access_key": sk,
                "security_token": securitytoken
            });
            //调用分段上传方法
            //必须参数：bucketName,uploadPath,videoFile,
            vodClient.uploadVideoFile({
                "bucketName": bucketName,
                "uploadPath": filePath,
                "videoFile": document.getElementById('MulitUploadFile').files[0]
            }, function (err, data) {
                //返回上传错误
                if (err) {
                    alert('err：' + err);
                    $(".progress-bar").css({
                        "background":"#ff8833"
                    });
                }
                //返回上传进度
                if (data) {
                    $(".progress-bar").css({
                        "background":"#3dcca6"
                    });
                    document.getElementById('progress').style.width = data + "%";
                    document.getElementById('progress_num').innerHTML = data + "%";
                }
            });
        }
    }

    /**
     *取消上传
     * */
    function cancelUpload() {
        vodClient && vodClient.upFlag && vodClient.cancelUpload(function (data) {
            $(".progress-bar").css({
                "background":"#ff8833"
            });
            alert(data);
        });
    }

    /**
     *续传
     * */
    function restartUpload() {
        vodClient && !vodClient.upFlag && vodClient.restartUpload(function(data){
            $(".progress-bar").css({
                "background":"#3dcca6"
            });
            alert(data);
        });
    }

    /**
     *显示选择的文件名称
     * */
    $("body").on("change", "input[type='file']", function () {
        if(!vodClient || vodClient.completedFlag || !vodClient.upFlag){
            var filePath = $(this).val();
            var arr = filePath.split('\\');
            var fileName = arr[arr.length - 1];
            $("#fileName").val(fileName).show();
            $(".progress-bar").css({
                "background":"#3dcca6"
            });
            document.getElementById('progress_num').innerHTML = "0%";
            document.getElementById('progress').style.width = "0%";
            if(vodClient) {
                vodClient = undefined;
            }
        }
    });
</script>
</body>
</html>
