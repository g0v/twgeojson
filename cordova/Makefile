before_prepare ::

after_prepare :: before_build

before_build ::
	cp strings.xml platforms/android/res/values/strings.xml

before_compile :: before_build

release :: platforms/android/bin/AIR-debug.apk copy after_prepare
	cd platforms/android ; yes $(MOEDICT_PASSWORD) | $(run) ant release

install ::
	-adb uninstall org.audreyt.dict.moe
	adb install -r platforms/android/bin/AIR-release.apk

fxos :: copy
	-mkdir platforms/firefoxos
	rsync -av --delete --copy-links base/* platforms/firefoxos
	rsync -av --delete --copy-links ../fxos platforms/firefoxos
	cp cordova-firefoxos.js platforms/firefoxos/cordova.js
	-rm package.zip
	cd platforms/firefoxos && zip -r ../../package.zip * && cd ../..
