/**
 * 活力赛场 3D 背景 —— Three.js
 * 元素：多赛道倾斜光环 + 双色上升粒子 + 飞奔的流光 + 鼠标视差
 * 用法：页面放置 <canvas id="bg3d" data-density="high|low"></canvas>
 */
(function () {
    var canvas = document.getElementById('bg3d');
    if (!canvas || typeof THREE === 'undefined') return;

    var high = canvas.getAttribute('data-density') !== 'low';
    var ringOpacity = high ? 0.55 : 0.3;

    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(58, window.innerWidth / window.innerHeight, 0.1, 120);
    camera.position.set(0, 2.6, 11);

    var renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    /* ---- 赛道光环：五条跑道线，配色 红/黄/蓝 交替，不同速度旋转 ---- */
    var rings = new THREE.Group();
    var ringConf = [
        { r: 5.6, tube: 0.045, color: 0xe04e36, tilt: 1.25, spd: 0.0030 },
        { r: 6.8, tube: 0.035, color: 0xd9a441, tilt: 1.20, spd: -0.0022 },
        { r: 8.0, tube: 0.045, color: 0xe04e36, tilt: 1.30, spd: 0.0016 },
        { r: 9.2, tube: 0.030, color: 0x4a9eda, tilt: 1.16, spd: -0.0012 },
        { r: 10.4, tube: 0.035, color: 0xd9a441, tilt: 1.35, spd: 0.0009 }
    ];
    var ringMeshes = [];
    ringConf.forEach(function (c) {
        var geo = new THREE.TorusGeometry(c.r, c.tube, 8, 100);
        var mat = new THREE.MeshBasicMaterial({ color: c.color, wireframe: true, transparent: true, opacity: ringOpacity });
        var m = new THREE.Mesh(geo, mat);
        m.rotation.x = c.tilt;
        m.userData.spd = c.spd;
        rings.add(m);
        ringMeshes.push(m);
    });
    rings.position.y = -3.6;
    scene.add(rings);

    /* ---- 粒子场：深灰 + 藏蓝 两群上升光点（亮底用普通混合） ---- */
    function buildPoints(count, color, size, opacity, speedMin, speedMax) {
        var pos = new Float32Array(count * 3);
        var spd = new Float32Array(count);
        for (var i = 0; i < count; i++) {
            pos[i * 3] = (Math.random() - 0.5) * 38;
            pos[i * 3 + 1] = Math.random() * 24 - 9;
            pos[i * 3 + 2] = (Math.random() - 0.5) * 24 - 4;
            spd[i] = speedMin + Math.random() * (speedMax - speedMin);
        }
        var geo = new THREE.BufferGeometry();
        geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
        var mat = new THREE.PointsMaterial({
            color: color, size: size, transparent: true, opacity: opacity,
            depthWrite: false
        });
        var pts = new THREE.Points(geo, mat);
        scene.add(pts);
        return { geo: geo, spd: spd, count: count };
    }
    var warm = buildPoints(high ? 460 : 230, 0x9aa2b1, 0.10, 0.5, 0.010, 0.030);
    var cool = buildPoints(high ? 380 : 190, 0x3a4a6e, 0.08, 0.4, 0.006, 0.020);

    /* ---- 流光：少量快速亮点沿跑道方向飞奔 ---- */
    var cometCount = high ? 14 : 7;
    var cometPos = new Float32Array(cometCount * 3);
    var cometAng = new Float32Array(cometCount);
    var cometRad = new Float32Array(cometCount);
    var cometSpd = new Float32Array(cometCount);
    for (var k = 0; k < cometCount; k++) {
        cometAng[k] = Math.random() * Math.PI * 2;
        cometRad[k] = 5.6 + Math.random() * 4.8;
        cometSpd[k] = 0.02 + Math.random() * 0.03;
    }
    var cometGeo = new THREE.BufferGeometry();
    cometGeo.setAttribute('position', new THREE.BufferAttribute(cometPos, 3));
    var cometMat = new THREE.PointsMaterial({
        color: 0xd9a441, size: 0.22, transparent: true, opacity: 0.9,
        depthWrite: false
    });
    scene.add(new THREE.Points(cometGeo, cometMat));

    /* ---- 鼠标视差 ---- */
    var mx = 0, my = 0;
    window.addEventListener('mousemove', function (e) {
        mx = (e.clientX / window.innerWidth - 0.5) * 2;
        my = (e.clientY / window.innerHeight - 0.5) * 2;
    });

    window.addEventListener('resize', function () {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });

    var running = true;
    document.addEventListener('visibilitychange', function () {
        running = !document.hidden;
        if (running) requestAnimationFrame(tick);
    });

    function rise(p) {
        var arr = p.geo.attributes.position.array;
        for (var i = 0; i < p.count; i++) {
            arr[i * 3 + 1] += p.spd[i];
            if (arr[i * 3 + 1] > 15) arr[i * 3 + 1] = -9;
        }
        p.geo.attributes.position.needsUpdate = true;
    }

    var t = 0;
    function tick() {
        if (!running) return;
        t += 0.006;

        ringMeshes.forEach(function (m) { m.rotation.z += m.userData.spd; });
        rings.position.y = -3.6 + Math.sin(t) * 0.35;
        rings.rotation.y = Math.sin(t * 0.4) * 0.08;

        rise(warm);
        rise(cool);

        // 流光沿各自轨道飞奔（在跑道平面内绕圈）
        var cp = cometGeo.attributes.position.array;
        for (var k = 0; k < cometCount; k++) {
            cometAng[k] += cometSpd[k];
            var a = cometAng[k], r = cometRad[k];
            cp[k * 3] = Math.cos(a) * r;
            cp[k * 3 + 1] = -3.6 + Math.sin(t + k) * 0.3 + Math.sin(a) * r * 0.32;
            cp[k * 3 + 2] = Math.sin(a) * r * 0.9 - 1;
        }
        cometGeo.attributes.position.needsUpdate = true;

        camera.position.x += (mx * 1.6 - camera.position.x) * 0.04;
        camera.position.y += (2.6 - my * 0.9 - camera.position.y) * 0.04;
        camera.lookAt(0, 0, 0);

        renderer.render(scene, camera);
        requestAnimationFrame(tick);
    }
    tick();
})();
