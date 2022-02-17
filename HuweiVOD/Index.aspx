<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="HuweiVOD.Index" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="./dist/indexStyle.css">
    <title>VOD-JS-SDK支持上传至点播桶</title>
</head>
<body>
<!-- 直接上传到点播桶 -->
<div class="box">
    <H1>视频点播服务上传JS-SDK示例</H1>
    <div class="warnTip">提示：
        <br/> 1、搭建租户服务端；
        <br/> 2、通过租户服务端向VOD获取临时AK,SK,返回给租户web客户端供SDK VodClient初始化使用；
        <br/> 3、通过租户服务端向VOD发起创建媒资，将媒资信息返回给租户web客户端供添加上传addAsset使用；
        <br/> 4、添加完媒资信息，调用startUpload开始上传；
        <br/> 5、客户端上传完毕，租户服务端向VOD发起确认媒资；
        <br/> 6、详细请参考
        <a target="_blank" href="https://support.huaweicloud.com/uploadsdk-vod/vod_06_0269.html">官网简介</a>。
    </div>
    <h3 class="title">VodClient初始化参数</h3>
    <input placeholder="access(AK)" id="app_Key" class="form-control" value="<% =credential.access %>"> 
    <input placeholder="secret(SK)" id="app_Secret" class="form-control" value="<% =credential.secret %>">
    <input placeholder="security_token" id="security_token" class="form-control" value="<% =credential.securitytoken %>">
    <input placeholder="项目ID" id="project_id" class="form-control" value="05c00605b7000f082fb5c012a462ced2">
    <input placeholder="VOD域名地址" id="vod_server" class="form-control" value="vod.cn-east-2.myhuaweicloud.com">
    <input placeholder="VOD域名地址端口号（可不填）" id="vod_port" class="form-control" value="">

    <h3 class="title">上传文件参数准备</h3>
    <div class="upload-param">
        <div class="asset-title">媒资信息1</div>
        <input placeholder="bucket" name="bucket" class="form-control" value="vfile">
        <input placeholder="location" name="location" class="form-control" value="cn-east-2">
        <input placeholder="object" name="object" class="form-control" value="mp4">
        <input placeholder="asset_id" name="asset_id" class="form-control" value="1111">
    </div>
    <button class="add-btn file">添加上传参数</button><br />
    <label for="">是否开启重复上传校验</label>
    <input type="radio" name="is_check" value="false" checked>否
    <input type="radio" name="is_check" value="true">是
    <br/>
    <br/>
    <label for="MulitUploadFile" class="file">选择文件</label>
    <input id="MulitUploadFile" type="file"  multiple="multiple" placeholder="请选择文件" style="display: none;">
    <button id="startUpload" class="file">开始上传</button>
    <br/>
    <!--进度条标签-->
    <table border="1" cellpadding="0" cellspacing="0" style="width: 100%;margin-bottom:40px;">
        <thead>
            <tr>
                <th width="30%">文件名</th>
                <th width="50%">上传进度</th>
                <th width="20%">操作</th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
</div>
</body>
<script src="./dist/jquery-3.3.1.min.js"></script>
<script src="./js-apig/moment.min.js"></script>
<script src="./js-apig/moment-timezone-with-data.min.js"></script>
<script src="./js-apig/hmac-sha256.js"></script>
<script src="./js-apig/signer.js"></script>
<script src="./dist/js-vod-sdk.min.js"></script>
<script>
    var vodClient;     // 实例声明
    var filesArr = []; //本地添加文件数组
    var canUpload = false;//是否可以开始上传
    /**
     *显示选择的文件名称
     * */
    $("body").unbind().on("change", "input[type='file']", function () {
        // 如果已初始化过，不再进行初始化操作。
        if(!vodClient){
            //构建vodClient实例 
            vodClient = new VodClient({
                // 临时凭证ak
                access_key_id:$('#app_Key').val(),
                // 临时凭证sk
                secret_access_key:$('#app_Secret').val(),
                // 临时凭证security_token
                security_token:$('#security_token').val(),
                // 项目ID
                project_id:$('#project_id').val(),
                // 终端节点Endpoint
                vod_server:$('#vod_server').val(),
                // 终端节点Endpoint端口号，默认值为空
                vod_port:$('#vod_port').val(),
                // 开始上传
                onUploadstarted:function(assetInfo) {
                    console.log(assetInfo.file.name + "开始上传");
                },
                // 上传进度
                onUploadProgress:function(assetInfo) {
                    // 设置上传进度
                    if (assetInfo.progress && (assetInfo.upFlag == "UPLOADING" || assetInfo.upFlag == "COMPLETE")) {
                        $(".progress-box[data-id="+ assetInfo.asset_id +"] .progress-bar").css({
                            "background":"#3dcca6"
                        });
                        $('.progress-bar[data-id='+ assetInfo.asset_id +']').css("width",assetInfo.progress + "%");
                        $('.progress_num[data-id='+ assetInfo.asset_id +']').html(assetInfo.progress + "%");
                    }
                },
                // 合并段成功
                onUploadSucceed:function(assetInfo) {
                    console.log(assetInfo.file.name+" 合并段成功");
                },
                // 上传失败
                onUploadFailed:function(assetInfo,err) {
                    // 进行上传失败处理
                    try {
                        console.log(assetInfo);
                        console.log(err);
                        if (err && assetInfo.upFlag == "FAILED") {
                            alert('err：' + err.msg);
                            $(".progress-box[data-id="+ assetInfo.asset_id +"] .progress-bar").css({
                                "background":"#ff8833"
                            });
                        }else if(err && assetInfo.upFlag == "REPEAT") {
                            for(var i = 0;i<filesArr.length;i++) {
                                if(filesArr[i].file.name == assetInfo.file.name) {
                                    filesArr.splice(i,1);
                                    $('tbody').find('tr[data-id='+ assetInfo.asset_id +']').remove();
                                    break;
                                }
                            }
                            alert('warning:' + err.msg);
                        }
                    }catch(err) {
                        console.log(err);
                    }
                },
                // 凭证超时过期
                // onUploadTokenExpired:function() {
                //     // 重新设置临时凭证并重新上传 setTimeout仅为模拟异步操作，实际获取凭证无需使用setTimeout
                //     setTimeout(function(){
                //         vodClient.resumeUpload("ak","sk","security_token");
                //     }, 300);
                // }
            })
        } 
        var files = document.getElementById('MulitUploadFile').files;
        // 是否进行重复校验
        var is_check = $('input[type=radio]:checked').val() === "true";
        // 选择视频是否重复标志
        var flag = false;
        // 前台判断选择视频是否重复
        $.each(files,function(index,value) {
            if(filesArr.length) {
                if(is_check) {
                    for(var i = 0;i<filesArr.length;i++) {
                        if(filesArr[i].file.name == value.name) {
                            alert("请勿重复上传相同视频");
                            flag = true;
                            break;
                        }
                    }
                }
                if(!flag) {
                    filesArr.push({file:value,added:false});
                }
            }else {
                filesArr.push({file:value,added:false});
            }
			console.log(JSON.stringify(filesArr));
        })
        if(flag) {
            $('#MulitUploadFile').val('');
            return;
        }
        // 添加媒资
        filesArr.forEach(function(value,index) {
            var random = Math.ceil(Math.random()*10) * 100;
            // 判断是否已添加过
            if(!value.added){ 
                // 模拟异步操作,媒资信息
                setTimeout(function() {
                    if($(".upload-param").eq(index).find('input[name=object]').val()) {
                        var tempArr1 = value.file.name.split('.');
                        var fileType = tempArr1[tempArr1.length-1];
                        var tempArr2 = $(".upload-param").eq(index).find('input[name=object]').val().split('.');
                        var objectType = tempArr2[tempArr2.length-1];
                        if(objectType.indexOf("_") >-1 ) {
                            objectType = objectType.substring(1);
                        }
						console.log('fileType:'+fileType+',objectType:'+objectType);
                        if(fileType.toLowerCase().indexOf(objectType.toLowerCase()) == -1) {
                            alert('媒资object的地址保存格式与文件格式不一致，请重新上传！');
                            filesArr.splice(-1,1);
                            $('#MulitUploadFile').val('');
                            return;
                        }
                    }
                    var data = {};
                    // 需要上传的文件
                    data.videoFile = value.file;
                    // 桶
                    data.bucket = $(".upload-param").eq(index).find('input[name=bucket]').val();
                    // region
                    data.location = $(".upload-param").eq(index).find('input[name=location]').val();
                    // 上传地址
                    data.object = $(".upload-param").eq(index).find('input[name=object]').val();
                    // 媒资ID
                    data.asset_id = $(".upload-param").eq(index).find('input[name=asset_id]').val();
                    // 是否进行上传重复校验
                    data.is_check = is_check;
                    // 添加到vodClient
                    try {
                        // 添加到上传列表
                        vodClient.addAsset(data);
                    }catch(err) {
                        // 资源重复或参数错误，都无法添加进上传列表
                        filesArr.splice(-1,1);
                        alert('err: ' + err);
                        $('#MulitUploadFile').val('');
                        return;
                    }
                    // 设置为不可上传
                    canUpload = false;
                    value.added = true;//设置为已添加到listsAsset
                    var html = '<tr data-id="'+ data.asset_id +'">' + 
                        '<td width="30%">' + data.videoFile.name + '</td>' +
                        '<td width="50%">' +
                            '<div class = "progress-box progress-box" data-id="'+ data.asset_id +'">'+
                                '<div id="progress" class="progress-bar" data-id="'+ data.asset_id +'"></div>'+
                                '<span id="progress_num" class="progress_num" data-id="'+ data.asset_id +'"></span>'+
                            '</div>'+
                        '</td>'+
                        '<td width="20%">'+
                            '<button class="file cancelUpload" data-id="'+ data.asset_id +'">取消</button>'+
                            '<button class="file restartUpload" data-id="'+ data.asset_id +'">续传</button>'+
                            '<button class="file startUploadForItem" data-id="'+ data.asset_id +'">上传</button>'+
                            '<button class="file delAsset" data-id="'+ data.asset_id +'">删除</button>'+
                        '</td>' + 
                    '</tr>';
                    $('tbody').append(html);
                    $('.progress_num[data-id='+ data.asset_id +']').html("0%");
                    $('.progress-bar[data-id='+ data.asset_id +']').css("width","0%");
                    // 查询上传列表，当选择文件数量与上传列表数量相同，则可以开始上传
                    var lists = vodClient.listAssets();
                    if(filesArr.length == lists.length) {
                        // 设置上传状态为true
                        canUpload = true;
                        $('#MulitUploadFile').val('');
                    }
                }, random);
            }
        })
    });
    /**
     * 添加上传媒资参数
     */
    $(".add-btn").click(function() {
        var html = '<div class="upload-param">' +
        '<div class="asset-title">媒资信息<span>'+ (+$('.upload-param').length + 1) +'</span><button style="margin-left:15px;" class="del-btn file">删除</button></div>' + 
        '<input placeholder="bucket" name="bucket" class="form-control" value="">' + 
        '<input placeholder="location" name="location" class="form-control" value="">' +
        '<input placeholder="object" name="object" class="form-control" value="">' +
        '<input placeholder="asset_id" name="asset_id" class="form-control" value="">' +
        '</div>';
        $(this).before(html);
    })

    // 删除媒资参数
    $('body').on('click','.del-btn',function() {
        $(this).parents('.upload-param').remove();
        $.each($('.upload-param'),function(index,value) {
            $(value).find('div>span').text(index+1);
        })
    })

    // 开始上传
    $('body').on('click','#startUpload',function() {
        if($('.upload-param').length != filesArr.length) {
            alert("媒资信息个数与上传文件个数必须相同");
            return;
        }
        if(!canUpload) {
            var lists = vodClient.listAssets();
            if (filesArr.length == lists.length) {
                // 设置上传状态为true
                canUpload = true;
                $('#MulitUploadFile').val('');
            }
        }
        if(canUpload) {
            vodClient.startUpload();
        }else {
            alert('视频还未准备好，请重试');
        }
    });
    // 取消上传
    $('body').on('click','.cancelUpload',function() {
        var index = $(this).parents('tr').index();
        var lists = vodClient && vodClient.listAssets();
        vodClient && lists[index].upFlag == "UPLOADING" && vodClient.cancelUpload(index,function (data) {
            $(".progress-box[data-id="+ lists[index].asset_id +"] .progress-bar").css({
                "background":"#ff8833"
            });
            alert(data);
        });
    })
    // 续传
    $('body').on('click','.restartUpload',function() {
        var index = $(this).parents('tr').index();
        var lists = vodClient && vodClient.listAssets();
        vodClient && (lists[index].upFlag == "CANCEL"  || lists[index].upFlag == "FAILED") && vodClient.restartUpload(index,function(data){
            $(".progress-box[data-id="+ lists[index].asset_id +"] .progress-bar").css({
                "background":"#3dcca6"
            });
            alert(data);
        });
    })
    // 单个视频开始上传
    $('body').on('click','.startUploadForItem',function() {
        var index = $(this).parents('tr').index();
        var lists = vodClient && vodClient.listAssets();
        vodClient && lists[index].upFlag == "WAITING" && vodClient.startUpload(index);
    })
    // 删除单个文件
    $('body').on('click','.delAsset',function() {
        var index = $(this).parents('tr').index();
        var lists = vodClient && vodClient.listAssets();
        filesArr.splice(index,1);
        vodClient && lists[index].upFlag != "UPLOADING" && vodClient.delListsAsset(index);
        $(this).parents('tr').remove();
    })
</script>

</html>