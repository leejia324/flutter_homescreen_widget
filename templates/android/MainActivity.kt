// ============================================================
// MainActivity.kt — 위젯 탭 액션 수신 처리
//
// 기존 MainActivity 에 아래 코드를 추가하세요.
// FlutterActivity 를 상속하는 구조 그대로 유지됩니다.
// ============================================================

package com.yourpackage // TODO: 본인 패키지명으로 교체

import android.content.Intent
import android.os.Bundle
import com.leejia.flutter_home_widget.FlutterHomeWidgetPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetAction(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetAction(intent)
    }

    private fun handleWidgetAction(intent: Intent?) {
        val actionId = intent?.getStringExtra("actionId") ?: return
        // 플러그인의 EventChannel 으로 전달 → Flutter onAction 스트림으로 수신
        FlutterHomeWidgetPlugin.sendAction(actionId)
    }
}
