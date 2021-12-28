/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#include "LAppDelegate.hpp"
#include <iostream>
#include <sstream>
#include <mach-o/dyld.h>
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include "LAppView.hpp"
#include "LAppPal.hpp"
#include "LAppDefine.hpp"
#include "LAppLive2DManager.hpp"
#include "LAppTextureManager.hpp"

using namespace Csm;
using namespace std;
using namespace LAppDefine;

static float bgDefaultColor = 0.0f;
namespace {
    LAppDelegate* s_instance = NULL;
}

LAppDelegate* LAppDelegate::GetInstance()
{
    if (s_instance == NULL)
    {
        s_instance = new LAppDelegate();
    }

    return s_instance;
}

void LAppDelegate::ReleaseInstance()
{
    if (s_instance != NULL)
    {
        delete s_instance;
    }

    s_instance = NULL;
}

bool LAppDelegate::Initialize()
{
    if (DebugLogEnable)
    {
        LAppPal::PrintLog("START");
    }

    // GLFWの初期化
    if (glfwInit() == GL_FALSE)
    {
        if (DebugLogEnable)
        {
            LAppPal::PrintLog("Can't initilize GLFW");
        }
        return GL_FALSE;
    }

    
    //specifies whether the window framebuffer will be transparent.
    glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER,GLFW_TRUE);
    //隐藏window的顶部最大化关闭按钮所在的栏
    glfwWindowHint(GLFW_DECORATED,GLFW_FALSE);
    //前置窗口
    glfwWindowHint(GLFW_FLOATING,GLFW_TRUE);
    
    
    // Windowの生成_
    _window = glfwCreateWindow(RenderTargetWidth, RenderTargetHeight, "Live2d", NULL, NULL);
    if (_window == NULL)
    {
        if (DebugLogEnable)
        {
            LAppPal::PrintLog("Can't create GLFW window.");
        }
        glfwTerminate();
        return GL_FALSE;
    }
    //测试
//    glfwSetInputMode(_window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    
    // Windowのコンテキストをカレントに設定
    glfwMakeContextCurrent(_window);
//    glfwSetWindowOpacity(_window, 0.5f);
    glfwSwapInterval(1);
    
    
    if (glewInit() != GLEW_OK) {
        if (DebugLogEnable)
        {
            LAppPal::PrintLog("Can't initilize glew.");
        }
        glfwTerminate();
        return GL_FALSE;
    }

    //テクスチャサンプリング設定
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    //透過設定
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    //コールバック関数の登録
    glfwSetMouseButtonCallback(_window, EventHandler::OnMouseCallBack);
    //mac上，当指针在应用外部是，会出现无法追踪指针的问题，但是应用内部倒是正常追踪
    glfwSetCursorPosCallback(_window, EventHandler::OnMouseCallBack);
    

    // ウィンドウサイズ記憶
    int width, height;
    glfwGetWindowSize(LAppDelegate::GetInstance()->GetWindow(), &width, &height);
    _windowWidth = width;
    _windowHeight = height;

    //AppViewの初期化
    _view->Initialize();

    // Cubism SDK の初期化
    InitializeCubism();

    SetRootDirectory();

    //load model
    LAppLive2DManager::GetInstance();

    //load sprite
    _view->InitializeSprite();

    return GL_TRUE;
}

void LAppDelegate::Release()
{
    // Windowの削除
    glfwDestroyWindow(_window);

    glfwTerminate();

    delete _textureManager;
    delete _view;

    // リソースを解放
    LAppLive2DManager::ReleaseInstance();

    //Cubism SDK の解放
    CubismFramework::Dispose();
}

void LAppDelegate::Run()
{
    //メインループ
    while (glfwWindowShouldClose(_window) == GL_FALSE && !_isEnd)
    {
        int width, height;
        glfwGetWindowSize(LAppDelegate::GetInstance()->GetWindow(), &width, &height);
        if((_windowWidth!=width || _windowHeight!=height) && width>0 && height>0)
        {
            _view->Initialize();
            _view->ResizeSprite();

            _windowWidth = width;
            _windowHeight = height;
        }

        // 時間更新
        LAppPal::UpdateTime();

        // 画面の初期化
        glClearColor(bgDefaultColor, bgDefaultColor, bgDefaultColor, bgDefaultColor);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glClearDepth(1.0);

        //描画更新
        _view->Render();

        // バッファの入れ替え
        glfwSwapBuffers(_window);

        // Poll for and process events
        glfwPollEvents();
    }
    
    bgDefaultColor = 0.0f;

    Release();

    LAppDelegate::ReleaseInstance();
}

void LAppDelegate::SetWindowSize(int width,int height)
{
    glfwSetWindowSize(LAppDelegate::GetInstance()->GetWindow(), width, height);
}

void LAppDelegate::ShowWindowResize(bool show)
{
    glfwSetWindowAttrib(LAppDelegate::GetInstance()->GetWindow(), GLFW_DECORATED, show ? GLFW_TRUE : GLFW_FALSE);
    glfwSetWindowAttrib(LAppDelegate::GetInstance()->GetWindow(), GLFW_RESIZABLE, show ? GLFW_TRUE : GLFW_FALSE);
    bgDefaultColor =  show ? 0.6f : 0.0f;
}

void LAppDelegate::CenterWindow()
{
    GLFWmonitor *monitor = glfwGetPrimaryMonitor();
    const GLFWvidmode* mode = glfwGetVideoMode(monitor);
    glfwSetWindowPos(LAppDelegate::GetInstance()->GetWindow(), (mode->width - _windowWidth) / 2, (mode->height - _windowHeight) / 2);
}

LAppDelegate::LAppDelegate():
    _cubismOption(),
    _window(NULL),
    _captured(false),
    _mouseBeginCaptrueX(0.0f),
    _mouseBeginCaptrueY(0.0f),
    _mouseX(0.0f),
    _mouseY(0.0f),
    _isEnd(false),
    _windowWidth(0),
    _windowHeight(0)
{
    _rootDirectory = "";
    _view = new LAppView();
    _textureManager = new LAppTextureManager();
}

void LAppDelegate::NextScene()
{
    LAppLive2DManager::GetInstance()->NextScene();
}

LAppDelegate::~LAppDelegate()
{

}

void LAppDelegate::InitializeCubism()
{
    //setup cubism
    _cubismOption.LogFunction = LAppPal::PrintMessage;
    _cubismOption.LoggingLevel = LAppDefine::CubismLoggingLevel;
    Csm::CubismFramework::StartUp(&_cubismAllocator, &_cubismOption);

    //Initialize cubism
    CubismFramework::Initialize();

    //default proj
    CubismMatrix44 projection;

    LAppPal::UpdateTime();
}

void LAppDelegate::OnMouseCallBack(GLFWwindow* window, int button, int action, int modify)
{
    if (_view == NULL)
    {
        return;
    }
    if (GLFW_MOUSE_BUTTON_LEFT != button)
    {
        return;
    }

    if (GLFW_PRESS == action)
    {
        _captured = true;
        _mouseBeginCaptrueX = _view->GetTouchX();
        _mouseBeginCaptrueY = _view->GetTouchY();
        _view->OnTouchesBegan(_mouseX, _mouseY);
    }
    else if (GLFW_RELEASE == action)
    {
        if (_captured)
        {
            _captured = false;
            _view->OnTouchesEnded(_mouseX, _mouseY);
        }
    }
}

void LAppDelegate::OnMouseCallBack(GLFWwindow* window, double x, double y)
{
    _mouseX = static_cast<float>(x);
    _mouseY = static_cast<float>(y);

    if (_view == NULL)
    {
        return;
    }
    
    
    if (_captured)
    {
        //x y 是相对window左上角的左边，不是屏幕坐标
        int originX = 0;
        int originY = 0;
        glfwGetWindowPos(_window, &originX, &originY);
        glfwSetWindowPos(_window, x+originX-_mouseBeginCaptrueX, y+originY-_mouseBeginCaptrueY);
        return;
    }
    
    _view->OnTouchesMoved(_mouseX, _mouseY);
}

void LAppDelegate::OnMouseMovedCallBack(GLFWwindow* window, double x, double y)
{
    if (_view == NULL)
    {
        return;
    }
    
    int originX = 0;
    int originY = 0;
    glfwGetWindowPos(_window, &originX, &originY);

    _view->OnTouchesMoved(static_cast<float>(x-originX), static_cast<float>(y-originY));
}


GLuint LAppDelegate::CreateShader()
{
    //バーテックスシェーダのコンパイル
    GLuint vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
    const char* vertexShader =
        "#version 120\n"
        "attribute vec3 position;"
        "attribute vec2 uv;"
        "varying vec2 vuv;"
        "void main(void){"
        "    gl_Position = vec4(position, 1.0);"
        "    vuv = uv;"
        "}";
    glShaderSource(vertexShaderId, 1, &vertexShader, NULL);
    glCompileShader(vertexShaderId);

    //フラグメントシェーダのコンパイル
    GLuint fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
    const char* fragmentShader =
        "#version 120\n"
        "varying vec2 vuv;"
        "uniform sampler2D texture;"
        "uniform vec4 baseColor;"
        "void main(void){"
        "    gl_FragColor = texture2D(texture, vuv) * baseColor;"
        "}";
    glShaderSource(fragmentShaderId, 1, &fragmentShader, NULL);
    glCompileShader(fragmentShaderId);

    //プログラムオブジェクトの作成
    GLuint programId = glCreateProgram();
    glAttachShader(programId, vertexShaderId);
    glAttachShader(programId, fragmentShaderId);

    // リンク
    glLinkProgram(programId);

    glUseProgram(programId);

    return programId;
}

void LAppDelegate::SetRootDirectory()
{
    char path[1024];
    uint32_t size = sizeof(path);
    _NSGetExecutablePath(path, &size);
    Csm::csmVector<string> splitStrings = this->Split(path, '/');

    this->_rootDirectory = "";
    for(int i = 0; i < splitStrings.GetSize() - 1; i++)
    {
        this->_rootDirectory = this->_rootDirectory + "/" +splitStrings[i];
    }
    this->_rootDirectory += "/";
    
    //实际位置与打包之后的资源位置不符合，所以另外设置资源位置，后续修改
    this->_rootDirectory = Live2d_RES;
}

Csm::csmVector<string> LAppDelegate::Split(const std::string& baseString, char delimiter)
{
    Csm::csmVector<string> elems;
    stringstream ss(baseString);
    string item;
    while(getline(ss, item, delimiter))
    {
        if(!item.empty())
        {
            elems.PushBack(item);
        }
    }
    return elems;
}
