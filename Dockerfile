FROM mono:6 AS builder

# Download VirtualRadarServer
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.tar.gz /tmp/files/VirtualRadar.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.LanguagePack.tar.gz /tmp/files/VirtualRadar.LanguagePack.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.WebAdminPlugin.tar.gz /tmp/files/VirtualRadar.WebAdminPlugin.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.DatabaseWriterPlugin.tar.gz /tmp/files/VirtualRadar.DatabaseWriterPlugin.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.CustomContentPlugin.tar.gz /tmp/files/VirtualRadar.CustomContentPlugin.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.DatabaseEditorPlugin.tar.gz /tmp/files/VirtualRadar.DatabaseEditorPlugin.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.TileServerCachePlugin.tar.gz /tmp/files/VirtualRadar.TileServerCachePlugin.tar.gz
ADD http://www.virtualradarserver.co.uk/Files/VirtualRadar.exe.config.tar.gz /tmp/files/VirtualRadar.exe.config.tar.gz

# Download Operator Logo Start Pack
#   - Instructions from: https://forum.virtualradarserver.co.uk/viewtopic.php?t=929
ADD http://www.woodair.net/SBS/Download/LOGO.zip /tmp/files/operator-logo-starter-pack.zip

# Script to get appropriate s6 overlay based on architecture
ADD scripts/get-s6.sh /opt/helpers/get-s6.sh

# Build container
RUN \
  apt-get update -y && \
  apt-get install --no-install-recommends -y \
    uuid-runtime \
    unzip \
    xmlstarlet \
    git && \
  mkdir -p /opt/VirtualRadar && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.tar.gz && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.LanguagePack.tar.gz && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.WebAdminPlugin.tar.gz && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.DatabaseWriterPlugin.tar.gz && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.CustomContentPlugin.tar.gz && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.DatabaseEditorPlugin.tar.gz && \
  tar -C /opt/VirtualRadar -xzf /tmp/files/VirtualRadar.TileServerCachePlugin.tar.gz && \
  tar -C /opt/VirtualRadar -xf /tmp/files/VirtualRadar.exe.config.tar.gz && \
  mkdir -p /config/operatorflags && \
  mkdir -p /config/silhouettes && \
  export HOME=/config && \
  echo "Starting VirtualRadarServer for 10 seconds to allow /config to be generated..." && \
  timeout 10 mono /opt/VirtualRadar/VirtualRadar.exe -nogui -createAdmin:`uuidgen -r` -password:`uuidgen -r` > /dev/null 2>&1 || true && \
  rm /config/.local/share/VirtualRadar/Users.sqb && \
  echo "Settings Silhouettes and Flags paths..." && \
  cp /config/.local/share/VirtualRadar/Configuration.xml /config/.local/share/VirtualRadar/Configuration.xml.original && \
  xmlstarlet ed -s "/Configuration/BaseStationSettings" -t elem -n SilhouettesFolder -v /config/silhouettes /config/.local/share/VirtualRadar/Configuration.xml.original > /config/.local/share/VirtualRadar/Configuration.xml && \
  cp /config/.local/share/VirtualRadar/Configuration.xml /config/.local/share/VirtualRadar/Configuration.xml.original && \
  xmlstarlet ed -s "/Configuration/BaseStationSettings" -t elem -n OperatorFlagsFolder -v /config/operatorflags /config/.local/share/VirtualRadar/Configuration.xml.original > /config/.local/share/VirtualRadar/Configuration.xml && \
  rm /config/.local/share/VirtualRadar/Configuration.xml.original && \
  echo "Downloading operator flags..." && \
  git clone --depth 1 https://github.com/dedevillela/VRS-Operator-Flags.git /opt/VRS_Extras/dedevillela/VRS-Operator-Flags && \
  mv /opt/VRS_Extras/dedevillela/VRS-Operator-Flags/CustomOperatorFlags.js /opt/VRS_Extras/dedevillela/VRS-Operator-Flags/CustomOperatorFlags.js.original && \
  echo "<script>" > /opt/VRS_Extras/dedevillela/VRS-Operator-Flags/CustomOperatorFlags.js && \
  cat /opt/VRS_Extras/dedevillela/VRS-Operator-Flags/CustomOperatorFlags.js.original >> /opt/VRS_Extras/dedevillela/VRS-Operator-Flags/CustomOperatorFlags.js && \
  echo "</script>" >> /opt/VRS_Extras/dedevillela/VRS-Operator-Flags/CustomOperatorFlags.js && \
  echo "Downloading silhouettes..." && \
  git clone --depth 1 https://github.com/dedevillela/VRS-Silhouettes.git /opt/VRS_Extras/dedevillela/VRS-Silhouettes && \
  mv /opt/VRS_Extras/dedevillela/VRS-Silhouettes/CustomSilhouette.js /opt/VRS_Extras/dedevillela/VRS-Silhouettes/CustomSilhouette.js.original && \
  echo "<script>" > /opt/VRS_Extras/dedevillela/VRS-Silhouettes/CustomSilhouette.js && \
  cat /opt/VRS_Extras/dedevillela/VRS-Silhouettes/CustomSilhouette.js.original >> /opt/VRS_Extras/dedevillela/VRS-Silhouettes/CustomSilhouette.js && \
  echo "</script>" >> /opt/VRS_Extras/dedevillela/VRS-Silhouettes/CustomSilhouette.js && \
  echo "Downloading country flags..." && \
  git clone --depth 1 https://github.com/dedevillela/VRS-Country-Flags.git /opt/VRS_Extras/dedevillela/VRS-Country-Flags && \
  echo "Downloading aircraft markers..." && \
  git clone --depth 1 https://github.com/dedevillela/VRS-Aircraft-Markers.git /opt/VRS_Extras/dedevillela/VRS-Aircraft-Markers && \
  cp -R /opt/VRS_Extras/dedevillela/VRS-Aircraft-Markers/Web/images/markers/* /opt/VirtualRadar/Web/images/markers && \
  echo "Unzipping Bones Aviation Operator Logo Starter Pack..." && \
  mkdir -p /opt/VRS_Extras/bonesaviation/operator-logo-starter-pack && \
  unzip /tmp/files/operator-logo-starter-pack.zip -d /opt/VRS_Extras/bonesaviation/operator-logo-starter-pack && \
  echo "Applying Custom Content Plugin Config..." && \
  echo "VirtualRadar.Plugin.CustomContent.Options=%3c%3fxml+version%3d%221.0%22%3f%3e%0a%3cOptions+xmlns%3axsd%3d%22http%3a%2f%2fwww.w3.org%2f2001%2fXMLSchema%22+xmlns%3axsi%3d%22http%3a%2f%2fwww.w3.org%2f2001%2fXMLSchema-instance%22%3e%0a++%3cDataVersion%3e3%3c%2fDataVersion%3e%0a++%3cEnabled%3efalse%3c%2fEnabled%3e%0a++%3cInjectSettings%3e%0a++++%3cInjectSettings%3e%0a++++++%3cEnabled%3etrue%3c%2fEnabled%3e%0a++++++%3cPathAndFile%3e*%3c%2fPathAndFile%3e%0a++++++%3cInjectionLocation%3eHead%3c%2fInjectionLocation%3e%0a++++++%3cStart%3efalse%3c%2fStart%3e%0a++++++%3cFile%3e%2fopt%2fVRS_Extras%2fdedevillela%2fVRS-Operator-Flags%2fCustomOperatorFlags.js%3c%2fFile%3e%0a++++%3c%2fInjectSettings%3e%0a++++%3cInjectSettings%3e%0a++++++%3cEnabled%3etrue%3c%2fEnabled%3e%0a++++++%3cPathAndFile%3e*%3c%2fPathAndFile%3e%0a++++++%3cInjectionLocation%3eHead%3c%2fInjectionLocation%3e%0a++++++%3cStart%3efalse%3c%2fStart%3e%0a++++++%3cFile%3e%2fopt%2fVRS_Extras%2fdedevillela%2fVRS-Silhouettes%2fCustomSilhouette.js+%3c%2fFile%3e%0a++++%3c%2fInjectSettings%3e%0a++++%3cInjectSettings%3e%0a++++++%3cEnabled%3etrue%3c%2fEnabled%3e%0a++++++%3cPathAndFile%3e*%3c%2fPathAndFile%3e%0a++++++%3cInjectionLocation%3eHead%3c%2fInjectionLocation%3e%0a++++++%3cStart%3efalse%3c%2fStart%3e%0a++++++%3cFile%3e%2fopt%2fVRS_Extras%2fdedevillela%2fVRS-Country-Flags%2fCustomAircraftMarkers.html%3c%2fFile%3e%0a++++%3c%2fInjectSettings%3e%0a++%3c%2fInjectSettings%3e%0a%3c%2fOptions%3e" > /config/.local/share/VirtualRadar/PluginsConfiguration.txt

# Prepare final container
FROM mono:6 AS final
ENV VERSION_S6OVERLAY=v1.22.1.0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    BASESTATIONPORT=30003 \
    HOME=/config
COPY --from=builder /opt /opt
COPY --from=builder /config /config
COPY etc /etc
RUN \
  apt-get update -y && \
  apt-get install -y --no-install-recommends \
    socat \
    sqlite3 && \
  echo "Create vrs user..." && \
  useradd --home-dir /home/vrs --skel /etc/skel --create-home --user-group --shell /usr/sbin/nologin vrs && \
  chown -R vrs:vrs /config && \
  echo "Get vrs version..." && \
  grep version /config/.local/share/VirtualRadar/VirtualRadarLog.txt | grep -oP 'Program started, version (\d+.(\d+.)+),' | cut -d ',' -f 2 | cut -d ' ' -f 3 | head -1 > /VERSION && \
  cat /VERSION && \
  echo "Install s6-overlay..." &&  \
  /opt/helpers/get-s6.sh && \
  tar -xzf /tmp/s6-overlay.tar.gz -C / && \
  echo "Clean up..." &&  \
  rm -rf /opt/helpers /tmp/* /var/cache/apk/*
EXPOSE 8080
ENTRYPOINT [ "/init" ]

