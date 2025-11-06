//
//  File.m
//  Muren
//
//  Created by lgc on 2025/11/6.
//


//type safe UserDefaults


BOOL_KEY(isNotFirstRun)
BOOL_KEY(HasLogined)
BOOL_KEY(HasSendToken)
BOOL_KEY(IsActivity)
BOOL_KEY(ShouldPlayIn4gNetwork)
STRING_KEY(UserName)
STRING_KEY(Password)

INTEGER_KEY(UserID)
INTEGER_KEY(ImageOrientation)
STRING_KEY(Token)

STRING_KEY(JsonRefreshDate)
STRING_KEY(ActivityTitle)
STRING_KEY(ActivityID)
STRING_KEY(DeviceToken)
//版本号.
STRING_KEY(CFBundleShortVersionString)
//引导页提示一次
BOOL_KEY(VersionChang_OneToken)
//判断文件是否
BOOL_KEY(DocumentFilesHaveBeenSavedToAlbum)

//已经删除的内容的时间
STRING_KEY(DeletedContentIDTime)

//远程推送过来.记录是哪个控制器
STRING_KEY(RemoteNotificationVC)

//反馈建议内容
STRING_KEY(FeedBackContentString)

//上传未审核内容id
STRING_KEY(UserUploadContentId)

//用户关注数是否有更改.
BOOL_KEY(UserFollowNumIsChang)

//是否是国内版
BOOL_KEY(IsChinaEdition)

//精选是否是第一次进入app..
BOOL_KEY(IsOnceEnterAPP)

//第一次安装显示广告，之后每次打开都不再显示
STRING_KEY(AppVersionStr)
INTEGER_KEY(ShowAdsTimes)

//推荐精选作品的Id
STRING_KEY(OverSeasContentIdString)

//用户登录成功的令牌.
STRING_KEY(UserLoginAccessTokenString)

//用户更新令牌过期的token
STRING_KEY(UserLoginRefreshTokenString)

//令牌过期时间戳
INTEGER_KEY(TokenExpires)

//用户令牌过期时间
STRING_KEY(UserTokenExpires)

//用户Refresh_token过期时间
STRING_KEY(UserRefreshTokenExpires)

//用户注册时的密码
STRING_KEY(UserPassword)

//用户的登录类型  0密码和邮箱都为空    1确认了邮箱   2确认了密码   3都确认
INTEGER_KEY(UserLoginStyle)

//服务器域名 旧
STRING_KEY(ServerAddressOld)

//服务器域名 新
STRING_KEY(ServerAddressNew)

//固件更新的消息数
INTEGER_KEY(FirmwareTips)

INTEGER_KEY(LatestUploadWayType)

//上次登录区域
STRING_KEY(LastLoginArea)

//记录上次签到的时间
STRING_KEY(IntegalDateStr)

//是否展示签到弹框
BOOL_KEY(IsShowIntegalView)

//是否存在存不到相册里的视频
BOOL_KEY(haveHighFrameVideo)

//是否存在音频文件
BOOL_KEY(IsHasAudioFile)

//登录注册随机产生的加密字符串
STRING_KEY(UserPasswordSaltStr)

//红点信息数
INTEGER_KEY(NewsMsgNumber)

//是否从消息栏进入
BOOL_KEY(IsMessageBoardEnter)

//保存A10音频文件名
STRING_KEY(GetA10AudionName)

//判断google是否授权
BOOL_KEY(IsGoogleAuthorization)

//地图类型
INTEGER_KEY(MapKind)


STRING_KEY(M828GHEdogUpdateTime)
STRING_KEY(M990EdogUpdateTime)
STRING_KEY(firmUpdateTime)

STRING_KEY(cameraProduct)

STRING_KEY(needDownloadProduct)
