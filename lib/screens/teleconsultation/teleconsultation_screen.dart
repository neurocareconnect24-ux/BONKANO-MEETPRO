import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/api_end_points.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../appointment/model/appointments_res_model.dart';
import '../appointment/video_call/video_call_screen.dart';

class TeleconsultationController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<AppointmentData> teleconsultations = <AppointmentData>[].obs;

  @override
  void onReady() {
    loadTeleconsultations();
    // Rafraîchir automatiquement toutes les 30 secondes
    _startAutoRefresh();
    super.onReady();
  }

  @override
  void onClose() {
    _stopAutoRefresh();
    super.onClose();
  }

  Worker? _refreshWorker;

  void _startAutoRefresh() {
    _refreshWorker = ever(teleconsultations, (_) {});
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (isClosed) return false;
      await _silentRefresh();
      return !isClosed;
    });
  }

  void _stopAutoRefresh() {
    _refreshWorker?.dispose();
  }

  /// Rafraîchissement silencieux (sans spinner de chargement)
  Future<void> _silentRefresh() async {
    if (!isLoggedIn.value) return;
    try {
      final response = await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.getAppointments}?per_page=50&page=1',
          method: HttpMethodType.GET,
        ),
      );

      final List<dynamic> appointmentList = response['data'] ?? [];
      final allAppointments = appointmentList.map((e) => AppointmentData.fromJson(e)).toList();

      teleconsultations.value = allAppointments.where((a) {
        return a.isVideoConsultancy || a.serviceType.toLowerCase().contains('online');
      }).toList();
    } catch (e) {
      log('TeleconsultationController silentRefresh error: $e');
    }
  }

  Future<void> loadTeleconsultations() async {
    if (!isLoggedIn.value) return;

    isLoading(true);
    try {
      final response = await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.getAppointments}?per_page=50&page=1',
          method: HttpMethodType.GET,
        ),
      );

      final List<dynamic> appointmentList = response['data'] ?? [];
      final allAppointments = appointmentList.map((e) => AppointmentData.fromJson(e)).toList();

      // Filtrer les rendez-vous de type téléconsultation/vidéo
      teleconsultations.value = allAppointments.where((a) {
        return a.isVideoConsultancy || a.serviceType.toLowerCase().contains('online');
      }).toList();
    } catch (e) {
      log('TeleconsultationController loadTeleconsultations error: $e');
    } finally {
      isLoading(false);
    }
  }
}

class TeleconsultationScreen extends StatelessWidget {
  TeleconsultationScreen({super.key});

  final TeleconsultationController controller = Get.put(TeleconsultationController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget: false,
      appBartitleText: locale.value.teleconsultation,
      isLoading: controller.isLoading,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.teleconsultations.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => controller.loadTeleconsultations(),
          child: AnimatedScrollView(
            padding: const EdgeInsets.only(bottom: 90, top: 8),
            children: [
              ...controller.teleconsultations.map((appointment) {
                return _TeleconsultationCard(
                  appointment: appointment,
                  onVideoCall: () {
                    if (appointment.status.toLowerCase() == 'confirmed' || appointment.status.toLowerCase() == 'check_in') {
                      Get.to(() => VideoCallScreen(), arguments: appointment);
                    } else {
                      toast(locale.value.oppsThisAppointmentIsNotConfirmedYet);
                    }
                  },
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: boxDecorationDefault(
              shape: BoxShape.circle,
              color: appColorPrimary.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.videocam_outlined, size: 64, color: appColorPrimary),
          ),
          24.height,
          Text(
            locale.value.noTeleconsultationsFound,
            style: boldTextStyle(size: 18),
          ),
          12.height,
          Text(
            locale.value.teleconsultationsWillAppearHere,
            style: secondaryTextStyle(size: 14),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: 32),
        ],
      ),
    );
  }
}

class _TeleconsultationCard extends StatelessWidget {
  final AppointmentData appointment;
  final VoidCallback onVideoCall;

  const _TeleconsultationCard({
    required this.appointment,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = appointment.status.toLowerCase() == 'confirmed' || appointment.status.toLowerCase() == 'check_in';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(16),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: radius(24),
              child: CachedImageWidget(
                url: appointment.userImage.validate(),
                height: 48,
                width: 48,
                fit: BoxFit.cover,
                circle: true,
              ),
            ),
            title: Text(
              appointment.userName.validate(),
              style: boldTextStyle(size: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                4.height,
                Text(
                  appointment.serviceName.validate(),
                  style: secondaryTextStyle(size: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: appColorPrimary),
                    4.width,
                    Text(
                      '${appointment.appointmentDate.validate()} - ${appointment.appointmentTime.validate()}',
                      style: secondaryTextStyle(size: 11, color: appColorPrimary),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildStatusBadge(),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital, size: 14, color: Colors.grey),
                      6.width,
                      Expanded(
                        child: Text(
                          appointment.clinicName.validate(),
                          style: secondaryTextStyle(size: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Video call button
                GestureDetector(
                  onTap: onVideoCall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isConfirmed ? appColorPrimary : Colors.grey.shade400,
                      borderRadius: radius(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam, color: Colors.white, size: 18),
                        6.width,
                        Text(
                          locale.value.videoCall,
                          style: boldTextStyle(size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText = appointment.status.validate();

    switch (statusText.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF4CAF50);
        statusText = locale.value.confirmed;
        break;
      case 'check_in':
        statusColor = const Color(0xFF2196F3);
        statusText = locale.value.checkIn;
        break;
      case 'pending':
        statusColor = const Color(0xFFFFC107);
        statusText = locale.value.pending;
        break;
      case 'cancelled':
        statusColor = cancelStatusColor;
        statusText = locale.value.cancelled;
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = locale.value.completed;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: radius(8),
      ),
      child: Text(
        statusText,
        style: boldTextStyle(size: 10, color: statusColor),
      ),
    );
  }
}
