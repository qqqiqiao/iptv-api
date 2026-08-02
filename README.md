## ~~(已失效)原变量如/abc123~~
## 所有 JS 需要变量值 统一为：/xymm 访问显示Forbidden或者其他提示 因链接后缀需要添加变量
## 统一变量 方便管理 变量更换是防止有人倒卖 
## 一键命令 
docker run -d -p 6001:6001 --name migu2026 qqt8520/migu2026:1.0

或者是：

docker run -d \
-p 6001:6001 \
--name migu2026 \
qqt8520/migu2026:1.0

解决非大陆服务器不能部署问题 访问方式： 部署后自己服务器IP+端口/频道id

如： CCTV2,http://115.58.151.196:1234/631780532

改成自己服务器：CCTV2,http://服务器IP:6001/631780532

更多频道参考：https://raw.githubusercontent.com/5d5d5f5f5f/10102/refs/heads/main/0623.txt
## ~~(已失效)免workers部署 ， 小白测试链接： https://2121.ccwu.cc~~
## 聚合搜索 免workers部署 ， 小白测试链接： https://9810.ccwu.cc


## 夸克网盘免费扩容1TB：https://pan.quark.cn/s/24e7633bbfaf
## 交流社区：http://45.192.97.170:8103
![图片1](https://raw.githubusercontent.com/5d5d5f5f5f/10102/main/9cf104d6331c5d2a05778a35bf6f1cfb.png
)
-----------------
## 不同文件夹JS访问：变量值说明
【TXT M3U 同一个变量值】，
【mitv  独立变量值】，
【合集  自定义变量值,仅OK影视APP使用】，
【聚合搜索 （无需变量值）部署后访问worker域名即可】
## 不同文件夹 'JS' 脚本部署后访问格式
例如：https://域名/变量值
示例：绑定的域名是 '123.com'  变量值是'abc123'
访问地址是：https://123.com/abc123
-----------------
## Mitv 原代码库升级（无需重新部署），变量值已更换，最新变量值公众号获取，建议使用DIYP ku9 OK影视等等能自动刷新接口的软件

## 聚合搜索 脚本升级 优化搜索速度  0516  0:25

-----------------
## 合集升级为可自定义设定变量 更新时间 05/12  12:35

## 0507 11:40 合集 安卓设备 OK壳专用订阅，其他软件用不了
## JS代码复制后：在worker代码编辑时键盘按下快捷键 ctrl+v  进行快速粘贴
安卓设备OK壳下载：
## TV版（横版）

[点击下载 TV版](https://www.mpimg.cn/down.php/df7b5a494782b2aececc26d7d42b63a4.apk&8520)

---

## 手机版（竖版）

[点击下载 手机版](https://www.mpimg.cn/down.php/133b58548d55398dc5522dc06b1579f6.apk&8520)

安卓极致播放器下载：
## 极致TV版（横版）

[点击下载 TV版](https://tv1288.xyz/极致.apk)
---


## TXT M3U   变量值公众号文章留言评论区自行查看获取


🔄 为什么要定期更换？

主要有以下几个原因：

1️⃣ 防止资源被倒卖牟利
如果链接长期固定，很容易被他人打包、二次售卖，甚至变成收费资源。

2️⃣ 避免被恶意滥用或封禁
固定链接一旦被大量传播或刷流量，很容易触发限制，导致全部用户无法使用。


针对不同类型壳子订阅使用的格式，提供两种格式部署脚本
## TXT订阅格式请部署`TXT`
## M3U订阅格式请部署`m3u`
![图片1](https://raw.githubusercontent.com/5d5d5f5f5f/10102/main/10.jpg)
![图片2](https://raw.githubusercontent.com/5d5d5f5f5f/10102/main/11.jpg)
![图片3](https://raw.githubusercontent.com/5d5d5f5f5f/10102/main/12.jpg)
# Cloudflare Worker 部署
## Cloudflare注册地址 https://dash.cloudflare.com

复制代码文件：`worker.js` 在Cloudflare 创建`Worker` 链接数据库自动更新订阅资源

---


 部署方法

### 1️⃣ 登录后台
登录 Cloudflare 后台

---

### 2️⃣ 进入 Workers
在左侧菜单找到：

👉 **Workers & Pages**

点击进入

---

### 3️⃣ 创建 Worker
依次点击：

👉 **Create Application（创建应用）**  
👉 **从 Hello World!开始**

然后点击：

👉 **Create Worker（创建 Worker）**
先创建worker再重新编辑更换脚本

---

## 编辑代码

进入后会看到默认代码：

javascript
export default {
  async fetch(request) {
    return new Response("Hello World!");
  }
}
把默认代码删除，替换为本项目 Worker 代码
点击右上角：

👉 Deploy（部署）

等待几秒即可完成部署
部署成功后，会生成一个访问地址，例如：

https://xxxx.workers.dev

直接在浏览器打开即可查看效果
绑定自定义域名（可选）

如果你有域名，可以绑定：

进入 Worker 设置
点击：
👉 Triggers（触发器）
添加：
👉 Custom Domain（自定义域名）

## 提示：CF部署的程序需要您当前网络可以正常访问才正常使用

## 使用

部署完成后，会生成一个内部地址：
或者绑定域名可公开访问地址
## 免费域名注册地址   https://my.dnshe.com
使用邀请码，您与好友各增加 1 个注册额度。
## 邀请码：FQE4D39C49
## 域名有效期10年或1年，看脸
![图片1](https://raw.githubusercontent.com/5d5d5f5f5f/10102/main/04331.png)

## 注册到托管视频教程 https://www.youtube.com/watch?v=7xi8Yh9csGo
## 云服务器推荐 [点击查看](https://prolxy.com/?i4b51d8)
公网流量
可用流量： 无限流量


# 版权说明


本项目仅供个人学习、研究及技术交流使用，严禁用于任何形式的商业用途。

任何人不得利用本项目从事包括但不限于盈利、传播、非法获取资源等行为，否则后果自负，与本项目作者无关。

使用者应在下载后 24 小时内自行删除全部内容，不得进行二次传播、分发或长期存储。

本项目不提供任何内容存储或分发服务，所有资源均来源于互联网公开信息，仅用于学习测试网络连通性与技术实现方式。

本项目不对资源的合法性、准确性、完整性作任何保证，也不承担任何直接或间接责任。

如本项目内容侵犯了您的合法权益，请及时联系删除，作者将在第一时间进行处理。

使用本项目即代表您已阅读并同意以上声明内容。
