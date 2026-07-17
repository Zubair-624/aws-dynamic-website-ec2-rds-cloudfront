#!/usr/bin/env python3
"""
Health check script - run by GitHub Actions after deployment
to verify the Flask app is actually responding correctly.
"""

import sys
import time
import requests

#-----Config-----
# CloudFront URL - update this after first terraform apply
SITE_URL     = "https://dp2ywvug89663.cloudfront.net"
HEALTH_URL   = f"{SITE_URL}/health"
MAX_RETRIES  = 10
RETRY_DELAY  = 15   # seconds between retries


def check_health():
    """Hit/Health and verify {"status": "ok"} is returned."""
    print(f"==> Checking: {HEALTH_URL}")

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = requests.get(HEALTH_URL, timeout=10)

            if response.status_code == 200:
                data = response.json()
                if data.get("status") == "ok":
                    print(f"✅ Health check passed (attempt {attempt})")
                    print(f"   Status code : {response.status_code}")
                    print(f"   Response    : {data}")
                    return True
                else:
                    print(f"⚠️  Unexpected response body: {data}")
            else:
                print(f"⚠️  Attempt {attempt}/{MAX_RETRIES} - status code: {response.status_code}")

        except requests.exceptions.ConnectionError:
            print(f"⚠️  Attempt {attempt}/{MAX_RETRIES} - connection refused, retrying...")
        except requests.exceptions.Timeout:
            print(f"⚠️  Attempt {attempt}/{MAX_RETRIES} - timeout, retrying...")
        except Exception as e:
            print(f"⚠️  Attempt {attempt}/{MAX_RETRIES} - error: {e}")

        if attempt < MAX_RETRIES:
            print(f"    Waiting {RETRY_DELAY}s before retry...")
            time.sleep(RETRY_DELAY)

    print(f"❌ Health check FAILED after {MAX_RETRIES} attempts")
    return False


def check_homepage():
    """Hit / and verify the visit counter appears in the response body."""
    print(f"\n==> Checking homepage: {SITE_URL}")
    try:
        response = requests.get(SITE_URL, timeout=15)
        if response.status_code == 200:
            if "visit_count" in response.text or "counter-number" in response.text:
                print("✅ Homepage loaded - visit counter found in response")
                return True
            else:
                print("⚠️  Homepage returned 200 but counter not found in body")
                return False
        else:
            print(f"❌ Homepage returned status: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Homepage check failed: {e}")
        return False


if __name__ == "__main__":
    print("=" * 50)
    print("  Deployment Health Check")
    print("=" * 50)

    health_ok   = check_health()
    homepage_ok = check_homepage()

    print("\n" + "=" * 50)
    print("  Results")
    print("=" * 50)
    print(f"  /health endpoint : {'✅ PASS' if health_ok else '❌ FAIL'}")
    print(f"  Homepage         : {'✅ PASS' if homepage_ok else '❌ FAIL'}")

    if health_ok and homepage_ok:
        print("\n✅ All checks passed - deployment successful")
        sys.exit(0)
    else:
        print("\n❌ Health check failed - deployment may have issues")
        sys.exit(1)