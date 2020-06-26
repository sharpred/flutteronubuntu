FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --fix-missing sudo bash curl wget vim gnupg less lsof net-tools git apt-utils libc6 libgcc1 libgl1 libstdc++6 libglu1-mesa libbz2-1.0 zip unzip default-jdk android-sdk -y

# WORKDIR
RUN mkdir /development
WORKDIR /development

#Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip
RUN mkdir /usr/lib/android-sdk/cmdline-tools && unzip commandlinetools-linux-6514223_latest.zip -d /usr/lib/android-sdk/cmdline-tools
ENV ANDROID_SDK_ROOT="/usr/lib/android-sdk"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"
ENV ANDROID_HOME="/usr/lib/android-sdk"

#Android Platform Tools
RUN ln -s /usr/lib/android-sdk/cmdline-tools/tools/bin/sdkmanager /usr/lib/android-sdk/tools/bin/
RUN yes | sdkmanager --install "platforms;android-28" && yes | sdkmanager --install "build-tools;28.0.3"

#Android Studio
RUN wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.0.16/android-studio-ide-193.6514223-linux.tar.gz
RUN tar -xvzf android-studio-ide-193.6514223-linux.tar.gz --directory /opt

ENV PATH="${PATH}:/development/flutter/bin:/opt/android-studio/bin"

# DART
RUN apt-get install apt-transport-https
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

RUN apt-get update
RUN apt-get install dart -y
ENV PATH="${PATH}:/usr/lib/dart/bin/"
ENV PATH="${PATH}:/root/.pub-cache/bin"

RUN pub global activate webdev
RUN pub global activate stagehand
RUN pub global activate peanut
RUN pub global activate grinder

#CHROME
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update
RUN apt-get install google-chrome-stable -y

# FLUTTER
RUN git clone https://github.com/flutter/flutter.git
RUN yes | flutter doctor --android-licenses
RUN flutter precache
RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web
RUN mkdir src && cd src && flutter create testapp
RUN cd /development/src/testapp && flutter build web