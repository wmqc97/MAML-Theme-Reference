# MAML 编写工具

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/sublime.html

MAML 编写工具最好用的还是 Sublime，启动快，插件多，加上 MAML 语法自动补全后非常高效，推荐大家使用。

## 安装 Sublime

下载地址直接百度，下面提供 MAML 常用插件的安装方法。

## 安装插件

首先安装 Package Control。Package Control 本身是一个方便管理插件的插件，安装后即可添加各种插件。

安装方法：点击菜单栏的 View，然后点击 Show Console（或直接输入 Ctrl+\`），在底部弹出的输入框中输入如下代码后按 Enter 键：

```
import urllib.request,os,hashlib; h = '6f4c264a24d933ce70df5dedcf1dcaee' + 'ebe013ee18cced0ef93d5f746d80ef60'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.cn/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```

如果安装失败（网络被墙），可以手动下载插件包安装。点击 首选项 → 浏览插件 打开插件目录，进入上一级文件夹找到 Installed Packages 文件夹，将下载的 Package Control.sublime-package 放入其中。

安装好 Package Control 后可以安装各种插件。先安装中文插件：点击 首选项 → Package Control，选择 Install Package，输入 chinese，选择第一个 ChineseLocalization。如果报错，手动下载安装后拷贝到 Installed Packages 目录。点击菜单栏中的 Help → Language → 简体中文。

安装完中文插件后安装 MAML 自动补全文件：下载后解压，点击 首选项 → 浏览插件 打开插件目录，将解压的 Maml 文件夹放到 Packages 目录下。点击 Sublime 右下角的 Plain Text，选择 XML 切换到 XML 语言下，MAML 自动补全会自动生效。输入尖括号 `<` 再输入标签名即可唤起补全。

推荐一个 Sublime 主题：模仿 VSCode 的 Palenight 主题。下载后拷贝到 Packages 目录，点击菜单栏中的 首选项，分别选择主题和配色方案为 Palenight。

**其他推荐插件：** SublimeLinter 可自动校验语法错误。安装完 SublimeLinter 后还需安装 SublimeLinter-xmllint，这样就可以对 XML 语法进行错误校验。

---

_最近更新时间：2020/12/30_
